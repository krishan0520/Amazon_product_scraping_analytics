import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Script generated for node AWS Glue Data Catalog
AWSGlueDataCatalog_node1698878540525 = glueContext.create_dynamic_frame.from_catalog(
    database="amazon_product_parquest_data",
    table_name="amozon_product_scrapping_data_eu_west_1_parquest",
    transformation_ctx="AWSGlueDataCatalog_node1698878540525",
)

# Script generated for node MySQL
MySQL_node1698878558206 = glueContext.write_dynamic_frame.from_catalog(
    frame=AWSGlueDataCatalog_node1698878540525,
    database="aws_products",
    table_name="aws_products_laptop_amazon",
    transformation_ctx="MySQL_node1698878558206",
)

job.commit()
