import boto3
import os
import glob

# Create s3 object 

s3 = boto3.client('s3')

bucket = "amozon-product-scrapping-data-eu-west-1"
file_path = "C:/Users/vimuk/OneDrive/Desktop/aws_products_project"

# Finding all json files 

json_files = glob.glob(os.path.join(file_path,"*.json"))

for file in json_files:
    
        s3_key = os.path.relpath(file,file_path)

        try:
                s3.upload_file(file,bucket,s3_key)
                print(f"uploaded_file:{s3_key}")

        except Exception as e:
                
                print(f"Error uploading {s3_key} : {str(e)}")
                
            
            
        

        
        







