# Microsoft Sentinel Deployment for T-Pot ingestion

The following deployment will deploy a Log analytics workspace with a defined *tpot_cl* custom table, a Data Collection Endpoint, and Data Collection Rule that will allow a Logstash Output Plugin: *microsoft-sentinel-logstash-output-plugin* to send T-Pot alerts and events. into Microsoft Sentinel.

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fswiftsolves-msft%2FAzure-TPot%2Fmain%2Fsample%2Ftpot_all%2Fdeployment%2Fazuredeploy.json)
[![Deploy To Azure US Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fswiftsolves-msft%2FAzure-TPot%2Fmain%2Fsample%2Ftpot_all%2Fdeployment%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fswiftsolves-msft%2FAzure-TPot%2Fmain%2Fsample%2Ftpot_all%2Fdeployment%2Fazuredeploy.json)

## Post Deployment

Be sure to manually configure T-Pot to use Microsoft Sentinel, [see here for directions:](https://github.com/swiftsolves-msft/Azure-TPot/tree/main/sample/tpot_all#azure-vm-t-pot-configuration)
