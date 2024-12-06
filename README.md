# Harbor Charts Checksum to OCI Migration Script

This script facilitates the migration of Helm charts from a checksum-based Harbor repository to a target Harbor instance using the OCI protocol.

## Configuration Variables

The following variables are used to define the details of the source and target Harbor instances:

### Source
- **SOURCE_HTTP_HOST**: HTTP URL of the source Harbor instance.  
  `https://harbor.navarcos.ccoe-nc.com`

- **SOURCE_CHARTS_API_ENDPOINT**: API endpoint for accessing charts in the source Harbor instance.  
  `https://harbor.navarcos.ccoe-nc.com/api/chartrepo/`

- **SOURCE_PROJECT**: Name of the source project from which charts will be migrated.  
  `navarcos`

- **SOURCE_REPO_CHART_ENTPOINT**: Endpoint of the source chart repository.  
  `https://harbor.navarcos.ccoe-nc.com/chartrepo/navarcos`

### Target
- **SINK_HTTPS_HOST**: HTTPS URL of the target Harbor instance.  
  `https://harbor.git.ccoe.internal`

- **SINK_PROJECTS_API_ENDPOINT**: API endpoint for managing projects in the target Harbor instance.  
  `$https://harbor.git.ccoe.internal/api/v2.0/projects`

- **SINK_OCI_HOST**: OCI URL for the target repository.  
  `oci://harbor.git.ccoe.internal`

- **SINK_PROJECT**: Name of the target project where charts will be migrated.  
  `project`

- **SINK_USERNAME**: Authentication username for the target Harbor instance.  
  `robot$project-robotname`

- **SINK_PASSWORD**: Authentication password for the target Harbor instance.  
  `password`

## Script Features

1. **Authentication**: Uses provided credentials to authenticate with both source and target Harbor instances.
2. **Chart Retrieval**: Queries the source repository to fetch charts.
3. **Push to Target Repository**: Pushes the charts to the target repository using the OCI protocol.

## Usage Example

### Prerequisites
- Ensure valid credentials for both source and target Harbor instances.
- Install the `helm` CLI.

### Running the Script
```bash
# Make the script executable
chmod +x migrate-charts.sh

# Run the script
./migrate-charts.sh
```

The script will migrate charts from the `navarcos` project in the source Harbor instance to the `test-harbor` project in the target instance.

## Important Notes

- **Security**: Avoid exposing sensitive credentials. It is recommended to use environment variables to manage usernames and passwords.
- **Connection Errors**: Ensure that both Harbor instances are reachable from the machine running the script.

## Troubleshooting

- **Authentication Failed**: Verify that the provided credentials are correct.
- **Timeouts**: Check your network connection and ensure that the Harbor endpoints are accessible.
