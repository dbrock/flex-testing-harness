test -z $FLEX3_HOME && { echo Please set \$FLEX3_HOME.; exit 1; }
export FLEX_HOME=$FLEX3_HOME
asautotest src/harness.mxml -o harness.swf \
  -I src -I melomel/src/main/flex \
  --static-typing --watch="*.{as,mxml}" \
  --demo-command="$FLEX3_HOME/bin/adl harness.xml"
