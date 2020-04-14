from diagrams import Cluster, Diagram
from diagrams.onprem.database import  Postgresql
from diagrams.onprem.search import Elasticsearch
from diagrams.onprem.monitoring import Kibana
from diagrams.onprem.compute import Server
from diagrams.azure.database import SQLDatabases
from diagrams.azure.storage import BlobStorage
from diagrams.azure.mobile import MobileEngagement, AppServiceMobile
from diagrams.gcp.ml import AutoML
from diagrams.onprem.compute import Server


with Diagram("Surfrider Foundation Europe",show=True):
    kibana = Kibana("Kibana")
    argis = Server("Arcgis")
    application_or_front = AppServiceMobile("Front")

    with Cluster("IA Backend"):
        ia = AutoML("IA")
        blob_storage = BlobStorage("Storage")
        
    with Cluster("Backend"):
        postgres = Postgresql("Postgres")
        elasticsearch = Elasticsearch("Elasticsearch")
        backend = Server("Backend")

    with Cluster("Devices"):
        phone = MobileEngagement("Phone")
        gopro = AppServiceMobile("GoPro")
    with Cluster("Labelisation Platform"):
        backend_label = Server("Backend")
        front_label = MobileEngagement("Labelisation Website")
        backend_label >> front_label >> backend_label
    
    backend_label >> blob_storage
    ia >> blob_storage >> ia 
    backend_label >> postgres
    gopro >> backend
    phone >> backend
    backend >> ia >> backend
    backend >> postgres >> argis >> application_or_front
    backend >> elasticsearch >> kibana