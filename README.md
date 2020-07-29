# Out-of-Shelf-Detectives
Out of Shelf Detectives

CreateModel.py
This Python code used for training and building ML model.
In order to build the model we extract sales tickets data from TDM Tlogs and build data file with a list of products in one row for etch ticket. We use this products file for ML model training.

CreateListFromModel.py
This Python code used for creating output file with Productid , Similar product , Score of similarity for all the products in the catalog. 
For each product in catalog there is call to ML model to receive similar products list and matching score. The result is written to a file that we are uploads to GCP BigQuery table for querying and analysis.
