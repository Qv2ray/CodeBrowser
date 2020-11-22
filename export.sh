#!/bin/bash

echo $QV2RAY_BUILD_BRANCH
PROJECT_ROOT_PATH=$PWD

git submodule update --init
cd woboq_codebrowser
mkdir build; cd build;
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel $(nproc)

cd $PROJECT_ROOT_PATH

OUTPUT_DIRECTORY=$PROJECT_ROOT_PATH/doc/$QV2RAY_BUILD_BRANCH
CLONE_ROOT=$PROJECT_ROOT_PATH/source/$QV2RAY_BUILD_BRANCH

mkdir -p $OUTPUT_DIRECTORY

git clone https://github.com/Qv2ray/Qv2ray $CLONE_ROOT
cd $CLONE_ROOT
git checkout $QV2RAY_BUILD_BRANCH
git fetch origin
git reset --hard origin/$QV2RAY_BUILD_BRANCH
git pull --verbose

git submodule update --init --recursive

mkdir code_build
cd code_build
cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_TESTING=ON -GNinja
cmake --build . --parallel $(nproc)
cd ..

$PROJECT_ROOT_PATH/woboq_codebrowser/build/generator/codebrowser_generator -b code_build -a -o $OUTPUT_DIRECTORY -p qv2ray:. -p :code_build
$PROJECT_ROOT_PATH/woboq_codebrowser/build/indexgenerator/codebrowser_indexgenerator $OUTPUT_DIRECTORY
cd $PROJECT_ROOT_PATH

cp -rvf $PROJECT_ROOT_PATH/woboq_codebrowser/data $PROJECT_ROOT_PATH/doc
cd $PROJECT_ROOT_PATH/doc
