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

echo 'generating rspec for models and controllers to $rootdir'

echo "Generating model specs"
for file in app/models/*.rb
do
  echo $file
  rails generate rspec:model $(basename $file .rb) -s
done

echo "Generating controller specs"
for file in app/controllers/*_controller.rb
do
  echo $file
  filename=$(basename $file)
  echo $filename
  rails generate rspec:controller ${filename%_controller.*} -s
done
