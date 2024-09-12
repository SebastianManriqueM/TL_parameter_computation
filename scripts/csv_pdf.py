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

index_file = 2
file_name   = ["ACSR_Electrical_Data" , "AAC_Electrical_Data", "ACAR_electrical_data_CME"]
first_substring = [ "Turkey" , "Peachbell", "Pelican"]
last_substring  = ["*STOCKED", "*STOCKED", "Kingfisher*"]

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
text = remove_text_before_substring(text, first_substring[index_file])
text = remove_text_after_substring( text, last_substring[index_file])
print(text)

rows = text.split("\n")
table = []
for row in rows:
    columns = row.split(" ")  # assuming space is the column delimiter
    columns = [col.strip() for col in columns if col]  # removing extra spaces
    if columns:  # ensuring the row is not empty
        table.append(columns)

        


# assuming the first row is the header
df = pd.DataFrame(table[0:], columns=table[0])

df.to_csv(csv_path, index=False)
