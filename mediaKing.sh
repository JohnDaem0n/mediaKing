#!/bin/bash

# Function to display usage information
usage() {
    clear

    echo "##\      ##\                 ##\ ##\                 ##\  ##\ ##\                     ";
    echo "###\    ### |                ## |\__|               ##  |##  |\__|                    ";
    echo "####\  #### | ######\   ####### |##\  ######\      ##  /##  / ##\ #######\   ######\  ";
    echo "##\##\## ## |##  __##\ ##  __## |## | \____##\    ##  /##  /  ## |##  __##\ ##  __##\ ";
    echo "## \###  ## |######## |## /  ## |## | ####### |  ##  / \##<   ## |## |  ## |## /  ## |";
    echo "## |\#  /## |##   ____|## |  ## |## |##  __## | ##  /   \##\  ## |## |  ## |## |  ## |";
    echo "## | \_/ ## |\#######\ \####### |## |\####### |##  /     \##\ ## |## |  ## |\####### |";
    echo "\__|     \__| \_______| \_______|\__| \_______|\__/       \__|\__|\__|  \__| \____## |";
    echo "                                                                            ##\   ## |";
    echo "                                                                            \######  |";
    echo "                                                                             \______/ ";

    echo "Usage: $0"
    echo "Options:"
    echo "  1. Set the search path"
    echo "  2. Set the date range (start date and end date)"
    echo "  3. Output listed files to a text file"
    echo "  4. List how many files match the criteria"
    echo "  5. List how much storage space is used by the files"
    echo "  6. ZIP files"
    echo "  7. Remove files that match the criteria"
    echo "  8. Create a folder with the date range as the name and move files"
    echo "  9. Quit"
    echo
    echo "Search Path: $search_path"
    echo "Date Range:  $start_date to $end_date"
    echo "Output File: $output_file"
    if [ -n "$list_count" ]; then
        echo "Number of Files: $list_count"
    fi
    if [ -n "$storage_space" ]; then
        echo "Storage Space Used: $storage_space"
    fi
}

# Function to update date range
update_date_range() {
    read -rp "Enter start date (YYYY-MM-DD): " start_date
    read -rp "Enter end date (YYYY-MM-DD): " end_date
}

# Function to update search path
update_search_path() {
    read -rp "Enter the search path: " search_path
}

# Function to update output file
update_output_file() {
    read -rp "Enter the output file name: " output_file
    ls "$search_path" > "$output_file"
    echo "Files listed in $output_file"
    list_count=$(find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date" | wc -l)
    storage_space=$(du -ch $(find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date") | grep total$)
}

# Function to update zip destination
update_zip_destination() {
    read -rp "Enter ZIP destination path: " zip_destination
}

# Function to create a folder with the date range as the name and move files
create_date_folder_and_move_files() {
    folder_name="${start_date}_to_${end_date}"
    mkdir -p "$search_path/$folder_name"
    echo "Folder '$folder_name' created."
    find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date" -exec mv {} "$search_path/$folder_name" \;
    echo "Files moved to '$search_path/$folder_name'."
    read -rp "Press Enter to continue..."
}

# Function to remove files that match the criteria
remove_files() {
    read -rp "Are you sure you want to remove files matching the criteria? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date" -exec rm {} \;
        echo "Files removed."
    else
        echo "No files were removed."
    fi
    read -rp "Press Enter to continue..."
}

# Initialize variables
search_path=""
start_date=""
end_date=""
output_file=""
zip_destination=""

# Menu loop
while true; do
    usage
    read -rp "Select an option (1-9): " choice
    case $choice in
        1)
            update_search_path
            ;;
        2)
            update_date_range
            ;;
        3)
            update_output_file
            ;;
        4)
            list_count=""
            storage_space=""
            list_count=$(find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date" | wc -l)
            storage_space=$(du -ch $(find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date") | grep total$)
            ;;
        5)
            du -ch $(find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date") | grep total$
            read -rp "Press Enter to continue..."
            ;;
        6)
            read -rp "Enter the name of the ZIP file (without .zip extension): " zip_filename
            zip -r "$zip_destination/$zip_filename.zip" $(find "$search_path" -type f -newermt "$start_date" ! -newermt "$end_date")
            echo "Files have been zipped to $zip_destination/$zip_filename.zip"
            read -rp "Press Enter to continue..."
            ;;
        7)
            remove_files
            ;;
        8)
            create_date_folder_and_move_files
            ;;
        9)
            exit
            ;;
        *)
            echo "Invalid option. Press Enter to continue..."
            read
            ;;
    esac
done
