#!/bin/bash


usage() {
   echo "Usage: $0 [command] [arg]"
   echo "   Examples: "
   echo "       $0 vol /html_dir"
   echo "       $0 s3 s3://myapp.com"
   exit 1
}


if [ $# -ne 2 ] ; then
    usage
else
    command=$1
    arg=$2
fi


# Prepare content
mkdir -p /tmp/workdir
cp -a $SRC_DIR/* /tmp/workdir


# Generate env-config.s
rm -f /tmp/workdir/env-config.js
touch /tmp/workdir/env-config.js

# Add assignment
echo "window._env_ = {" >> /tmp/workdir/env-config.js

# Read each line in .env file
# Each line represents key=value pairs
while read -r line || [[ -n "$line" ]];
do
  # Split env variables by character `=`
  if printf '%s\n' "$line" | grep -q -e '='; then
    varname=$(printf '%s\n' "$line" | sed -e 's/=.*//')
    varvalue=$(printf '%s\n' "$line" | sed -e 's/^[^=]*=//')
  fi

  # Read value of current variable if exists as Environment variable
  value=$(printf '%s\n' "${!varname}")
  # Otherwise use value from .env file
  [[ -z $value ]] && value=${varvalue}

  # Append configuration property to JS file
  echo "  $varname: \"$value\"," >> /tmp/workdir/env-config.js
done < $SRC_DIR/.env

echo "}" >> /tmp/workdir/env-config.js

case "$command" in
  vol) cp -a /tmp/workdir/* $arg;;
  s3) aws s3 sync /tmp/workdir $arg --delete --acl public-read;;
  *) echo "Command unknown"; usage;;
esac

rm -rf /tmp/workdir