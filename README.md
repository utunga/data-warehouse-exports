# data-warehouse-exports

Repository in which live python files that run (on an regular schedule) to export data from the Financial Data Warehouse


## How to run locally 

The contents of this directory are just python scripts, designed to be run as part of the regularly scheduled jobs. 

However they expect to be run in a python environment. To emulate that environment locally you need to create a conda virtual environment with the relevant packages installed.

1. Create environment (only needed once, may take a while) 

	C:\..\data-warehouse-exports>conda env create -f environment.yml

	Using Anaconda Cloud api site https://api.anaconda.org
	Fetching package metadata ...........
	Solving package specifications: ..........
	Linking packages ...
	[      COMPLETE      ]|##################################################| 100%

1. Activate environment 

	C:\...>activate DataWarehouseExports

1.	Run script (for example)

	(DataWarehouseExports) C:\...>python trace_export.py

	querying db..
	exporting to csv trace_monthly.csv
	done


## How to update environment.yml

If you want to add new packages required by a script in this directory this is a two step process.

1. Add the package in question

	(DataWarehouseExports) C:\...> conda install some_package_or_other

1. Update environment.yml

	(DataWarehouseExports) C:\...> conda env export > environment.yml


