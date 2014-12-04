if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1
fi

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 1
fi

ROOTDIR="$1"
echo $ROOTDIR

if [ ! -d "$ROOTDIR" ]; then
  echo "$ROOTDIR is not a directory"
  exit 1
fi

cd $ROOTDIR
FILE=Gemfile

if [ -f $FILE ];
then
   echo "File $FILE exists."
else
   echo "File $FILE does not exist."
   exit 1
fi

echo 'removing testify to $rootdir'
git checkout -- .
rm -r .rspec
rm -r .simplecov
rm -r config/cucumber.yml
rm -r features/
rm -r lib/tasks/cucumber.rake
rm -r script/
rm -r spec/
rm -r coverage/
rm -r test-reports/


