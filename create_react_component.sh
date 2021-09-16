#!/bin/bash

path=./components/$1
name=$2
cd $path
mkdir $name
cd ./$name
touch index.js
echo "export {default} from './$name.js'" > index.js
touch $name.js

echo "
import React from 'react'
import s from './$name.module.css'

const $name = ({}) => {

	return (
		<>

		</>
	);
};

export default $name" > $name.js

touch $name.module.css

echo "$path"
