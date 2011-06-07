asautotest harness.mxml -o harness.swf \
  -I . -l melomel-*.swc \
  --static-typing --watch="*.{as,mxml}" \
  --demo-command="$FLEX_HOME/bin/adl harness.xml"
