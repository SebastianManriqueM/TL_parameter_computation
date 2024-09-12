import PyPDF2
import pandas as pd

def remove_text_before_substring(s, substring):
    # Find the index of the substring
    index = s.find(substring)
    
    # If the substring is found, return the part of the string after the substring
    if index != -1:
        return s[index:]
    else:
        # If the substring is not found, return the original string
        return s
    
def remove_text_after_substring(s, substring):
    # Find the index of the substring
    index = s.find(substring)
    
    # If the substring is found, return the part of the string before the substring ends
    if index != -1:
        return s[:index]
    else:
        # If the substring is not found, return the original string
        return s

def eliminate_spaces_of_names( original_string, substring ):
    if substring in original_string:
        # Find the start and end indices of the substring
        start_index = original_string.find(substring)
        end_index = start_index + len(substring)
        
        # Extract the substring and replace spaces with underscores
        modified_substring = original_string[start_index:end_index].replace(" ", "_")
        
        # Replace the original substring with the modified substring
        modified_string = original_string[:start_index] + modified_substring + original_string[end_index:]

    return modified_string

index_file = 3
file_name   = ["ACSR_Electrical_Data" , "AAC_Electrical_Data", "ACAR_electrical_data_CME", "ACCC_electrical_data_ctc"]
first_substring = [ "Turkey" , "Peachbell", "Pelican", "OCEANSIDE"]
last_substring  = ["*STOCKED", "*STOCKED", "Kingfisher*", "SR Bluebird"]

folder_name = "cable_data"
pdf_path    = folder_name + "/" + file_name[index_file] + ".pdf"

csv_path   = folder_name + "/" + file_name[index_file] + ".csv"



file = open( pdf_path, 'rb' )
pdf = PyPDF2.PdfReader(file)

for page_num in range(len(pdf.pages)):
    page = pdf.pages[page_num]
    text = page.extract_text()
    print(text)

text = remove_text_before_substring(text, first_substring[index_file])
if index_file == 2:
    text = remove_text_before_substring(text, first_substring[index_file])
text = remove_text_after_substring( text, last_substring[index_file])

if index_file == 3:
    names_to_fix = ["CORPUS CHRISTI", "FORT WORTH", "EL PASO", "SAN ANTONIO"]
    for name in names_to_fix:
        text = eliminate_spaces_of_names( text, name )

print("\n\n",text)

rows = text.split("\n")
table = []
n_col = len( rows[0].split(" ") )
i=1
for row in rows:
    columns = row.split(" ")  # assuming space is the column delimiter
    columns = [col.strip() for col in columns if col]  # removing extra spaces
    
    while n_col > len(columns):
        columns.append("ND")
    print(i, "\t", len(columns))
    if columns:  # ensuring the row is not empty
        table.append(columns)
    i=i+1

        


# assuming the first row is the header
df = pd.DataFrame(table[0:], columns=table[0])

df.to_csv(csv_path, index=False)
