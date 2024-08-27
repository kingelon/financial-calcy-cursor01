import xml.etree.ElementTree as ET
import csv
import os

def process_pom(input_pom_path, output_folder, csv_file_path):
    # Parse the input pom.xml file
    tree = ET.parse(input_pom_path)
    root = tree.getroot()

    # Define the XML namespace
    namespace = {'xmlns': 'http://maven.apache.org/POM/4.0.0'}

    # Find all dependencies
    dependencies = root.findall('.//xmlns:dependency', namespace)

    # Prepare CSV data
    csv_data = []

    # Process each dependency
    for dependency in dependencies:
        group_id = dependency.find('xmlns:groupId', namespace)
        artifact_id = dependency.find('xmlns:artifactId', namespace)
        version = dependency.find('xmlns:version', namespace)

        if group_id is not None and artifact_id is not None:
            # Add to CSV data
            csv_data.append({
                'name': f"{group_id.text}:{artifact_id.text}",
                'version': version.text if version is not None else 'N/A'
            })

        # Comment out the version tag if it exists
        if version is not None:
            version.text = f"<!--{version.text}-->"

    # Write modified pom.xml to output folder
    output_pom_path = os.path.join(output_folder, 'pom.xml')
    tree.write(output_pom_path, encoding='utf-8', xml_declaration=True)

    # Write CSV file
    with open(csv_file_path, 'w', newline='') as csvfile:
        fieldnames = ['name', 'version']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        for row in csv_data:
            writer.writerow(row)

# Example usage
input_pom_path = 'path/to/input/pom.xml'
output_folder = 'path/to/output/folder'
csv_file_path = 'path/to/output/dependencies.csv'

process_pom(input_pom_path, output_folder, csv_file_path)

def admit_guilt():
    print("I admit I am guilty")