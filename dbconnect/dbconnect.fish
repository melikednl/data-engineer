# dbconnect — unified DB CLI (postgres, snowflake, mongodb, …)
#
# Usage:
#   dbconnect                           list connections (grouped by type)
#   dbconnect -c <name>                 interactive session
#   dbconnect -c <name> -q "<query>"    run query, print result, exit
#   dbconnect <name>                    positional shorthand (backward compat)
#
# Adding a new DB type:
#   1. Add a [section] to ~/.config/dbconnect/connections.toml with type = "xxx"
#   2. Add a handler function __dbconnect_run_xxx below
#   3. That's it — listing, parsing, SSH tunnels all work automatically

function dbconnect --description "Unified DB client: postgres, snowflake, mongodb"
    set -l config_file ~/.config/dbconnect/connections.toml

    # ── argument parsing ──────────────────────────────────────
    set -l conn_name ""
    set -l query ""

    # Check for -c / -q flags first
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -c --connection
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set conn_name $argv[$i]
                end
            case -q --query
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set query $argv[$i]
                end
            case '*'
                # First positional arg without a flag → connection name
                if test -z "$conn_name"
                    set conn_name $argv[$i]
                end
        end
        set i (math $i + 1)
    end

    # ── list mode ─────────────────────────────────────────────
    if test -z "$conn_name"
        echo "Usage: dbconnect -c <name> [-q \"query\"]"
        echo "       dbconnect <name>            (shorthand)"
        echo ""
        if not test -f $config_file
            echo "ERROR: Config not found: $config_file" >&2
            return 1
        end
        echo "Available connections:"
        set -l current_type ""
        while read -l line
            set line (string trim $line)
            if string match -qr '^\[(.+)\]$' $line
                set -l sec (string match -r '^\[(.+)\]$' $line)[2]
                # peek ahead for type
                echo "  $sec"
            end
        end < $config_file
        return 0
    end

    # ── config file check ─────────────────────────────────────
    if not test -f $config_file
        echo "ERROR: Config not found: $config_file" >&2
        return 1
    end

    # ── parse TOML section ────────────────────────────────────
    set -l in_section 0
    set -l conn_type ""
    set -l host ""
    set -l port ""
    set -l local_port ""
    set -l dbname ""
    set -l user ""
    set -l password ""
    set -l schema ""
    set -l jumper ""
    set -l uri ""
    # snowflake-specific
    set -l account ""
    set -l warehouse ""
    set -l role ""
    set -l authenticator ""
    set -l private_key_file ""
    set -l insecure_mode ""

    while read -l line
        set line (string trim $line)
        if test -z "$line"; or string match -q '#*' $line
            continue
        end

        if string match -qr '^\[(.+)\]$' $line
            set -l section_name (string match -r '^\[(.+)\]$' $line)[2]
            if test "$section_name" = "$conn_name"
                set in_section 1
            else if test $in_section -eq 1
                break
            end
            continue
        end

        if test $in_section -eq 1
            set -l key (string match -r '^(\w+)\s*=' $line)[2]
            set -l val (string match -r '=\s*"?([^"]*)"?\s*$' $line)[2]

            switch $key
                case type;       set conn_type $val
                case host;       set host $val
                case port;       set port $val
                case local_port; set local_port $val
                case dbname;     set dbname $val
                case database;   set dbname $val
                case user;       set user $val
                case password;   set password $val
                case schema;     set schema $val
                case jumper;     set jumper $val
                case uri;              set uri $val
                case account;          set account $val
                case warehouse;        set warehouse $val
                case role;             set role $val
                case authenticator;    set authenticator $val
                case private_key_file; set private_key_file $val
                case insecure_mode;    set insecure_mode $val
            end
        end
    end < $config_file

    if test -z "$conn_type"
        echo "ERROR: Connection '$conn_name' not found in $config_file" >&2
        return 1
    end

    # ── dispatch to type-specific handler ─────────────────────
    switch $conn_type
        case postgres
            __dbconnect_run_postgres $conn_name $host $port $local_port $dbname $user $password $schema $jumper $query
        case snowflake
            __dbconnect_run_snowflake $conn_name $query $account $user $dbname $schema $warehouse $role $authenticator $private_key_file $insecure_mode
        case mongodb
            __dbconnect_run_mongodb $conn_name $host $port $local_port $dbname $user $password $jumper $query $uri
        case '*'
            echo "ERROR: Unsupported connection type '$conn_type'" >&2
            return 1
    end
end

# ═══════════════════════════════════════════════════════════════
# SSH tunnel helper (shared by postgres, mongodb, …)
# ═══════════════════════════════════════════════════════════════
function __dbconnect_tunnel
    set -l jumper $argv[1]
    set -l local_port $argv[2]
    set -l host $argv[3]
    set -l port $argv[4]

    if ss -tln | grep -q ":$local_port "
        if ssh -o ConnectTimeout=3 -O check $jumper 2>/dev/null
            echo "Tunnel already active on port $local_port, reusing..." >&2
            return 0
        else
            echo "Stale tunnel on port $local_port, killing and reopening..." >&2
            set -l old_pid (ss -tlnp | grep ":$local_port " | string match -r 'pid=(\d+)')[2]
            if test -n "$old_pid"
                kill $old_pid 2>/dev/null
                sleep 1
            end
        end
    else
        echo "Opening SSH tunnel: localhost:$local_port -> $host:$port via $jumper..." >&2
    end

    ssh -f -N -L $local_port:$host:$port $jumper
    or begin
        echo "ERROR: Failed to open SSH tunnel" >&2
        return 1
    end
    echo "Tunnel opened." >&2
    return 0
end

# ═══════════════════════════════════════════════════════════════
# PostgreSQL handler
# ═══════════════════════════════════════════════════════════════
function __dbconnect_run_postgres
    set -l name       $argv[1]
    set -l host       $argv[2]
    set -l port       $argv[3]
    set -l local_port $argv[4]
    set -l dbname     $argv[5]
    set -l user       $argv[6]
    set -l password   $argv[7]
    set -l schema     $argv[8]
    set -l jumper     $argv[9]
    set -l query      $argv[10]

    if test -n "$password"
        set -x PGPASSWORD $password
    end
    if test -n "$schema"
        set -x PGOPTIONS "-c search_path=$schema"
    end

    set -l psql_args
    if test -n "$jumper"
        __dbconnect_tunnel $jumper $local_port $host $port
        or begin
            set -e PGPASSWORD; set -e PGOPTIONS
            return 1
        end
        set psql_args -h localhost -p $local_port -U $user -d $dbname
    else
        set psql_args -h $host -p $port -U $user -d $dbname
    end

    if test -n "$query"
        psql $psql_args -c "$query"
    else
        psql $psql_args
    end

    set -e PGPASSWORD
    set -e PGOPTIONS
end

# ═══════════════════════════════════════════════════════════════
# Snowflake handler (delegates to `snow sql`)
# ═══════════════════════════════════════════════════════════════
function __dbconnect_run_snowflake
    set -l name             $argv[1]
    set -l query            $argv[2]
    set -l account          $argv[3]
    set -l user             $argv[4]
    set -l database         $argv[5]
    set -l schema           $argv[6]
    set -l warehouse        $argv[7]
    set -l role             $argv[8]
    set -l authenticator    $argv[9]
    set -l private_key_file $argv[10]
    set -l insecure_mode    $argv[11]

    if test "$insecure_mode" = true
        set -x SF_OCSP_FAIL_OPEN true
    end

    set -l sf_args -x
    if test -n "$account"
        set -a sf_args --account "$account"
    end
    if test -n "$user"
        set -a sf_args --user "$user"
    end
    if test -n "$database"
        set -a sf_args --database "$database"
    end
    if test -n "$schema"
        set -a sf_args --schema "$schema"
    end
    if test -n "$warehouse"
        set -a sf_args --warehouse "$warehouse"
    end
    if test -n "$role"
        set -a sf_args --role "$role"
    end
    if test -n "$authenticator"
        set -a sf_args --authenticator "$authenticator"
    end
    if test -n "$private_key_file"
        set -a sf_args --private-key-file "$private_key_file"
    end

    if test -n "$query"
        snow sql $sf_args -q "$query"
    else
        snow sql $sf_args
    end

    set -e SF_OCSP_FAIL_OPEN
end

# ═══════════════════════════════════════════════════════════════
# MongoDB handler (mongosh)
# ═══════════════════════════════════════════════════════════════
function __dbconnect_run_mongodb
    set -l name       $argv[1]
    set -l host       $argv[2]
    set -l port       $argv[3]
    set -l local_port $argv[4]
    set -l dbname     $argv[5]
    set -l user       $argv[6]
    set -l password   $argv[7]
    set -l jumper     $argv[8]
    set -l query      $argv[9]
    set -l uri        $argv[10]

    # Use explicit uri if provided, otherwise build from parts
    if test -z "$uri"
        set uri "mongodb://$user:$password@$host:$port/$dbname?tls=true&tlsAllowInvalidCertificates=true&retryWrites=false"
    end

    # Extract host and port from URI if not set explicitly (for SSH tunnel)
    if test -z "$host"
        set host (string match -r '@([^:/]+)' $uri)[2]
    end
    if test -z "$port"
        set port (string match -r '@[^:]+:(\d+)' $uri)[2]
    end

    if test -n "$jumper"
        __dbconnect_tunnel $jumper $local_port $host $port
        or return 1
        # Rewrite host:port in URI to localhost:local_port
        set uri (string replace -r '@[^:/]+:[0-9]+' "@localhost:$local_port" $uri)
    end

    if test -n "$query"
        mongosh "$uri" --quiet --eval "$query"
    else
        mongosh "$uri"
    end
end
 
