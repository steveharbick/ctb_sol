import sys
import os
import zipfile
import shutil
from pandas import DataFrame
from lxml import etree


"""
BEGIN Script configuration settings.  
"""
#[OPTIONAL] The directory to find files from CTB, AKA "frompems".  If passed as parameter, this will be ignored.  If blank, user will be prompted to enter.
frompems = "/Volumes/Steve/Work/CTB/frompems/"

#[OPTIONAL] The directory to put folders of files after processing.  If passed as parameter, this will be ignored.  If blank, user will be prompted to enter.
processed = "/Volumes/Steve/Work/CTB/wip/"

# The name of folder to put zip files after extraction 
compressed = "frompems_compressed" 

# The name of folder to put tsv files 
tsv = "to_model"

# The name of folder to put pickle files
pickle = "frompems_pickle"

# The name of folder to put xml files
xml ="frompems_xml"

"""
END Script configuration settings.  
"""


#Logic to determine if directory instructions are passed in as script parameter, defined in script, or should be prompted for.
if len(sys.argv) == 3:
    frompems = sys.argv[1]  
    processed = sys.argv[2] 
    
else:
    try:
        frompems 
    except NameError:   
         print "What is the path for files frompems?"
         frompems = raw_input("> ")
    try:
        processed
    except NameError:   
         print "What is the path to stores files after processing?"
         processed = raw_input("> ")


# Check if folders exist and if not, then exit.
if os.path.isdir(frompems) == False: sys.exit("Please check source directory, e.g.'frompems', then try again.")
if os.path.isdir(processed) == False: sys.exit("Please create destination directory then try again.")


#create directory for zip files after decompression
commdir = os.path.join(processed, compressed)
if os.path.isdir(commdir) == False: os.mkdir(commdir)

#create directory for tab separated files after creation
tsvdir = os.path.join(processed, tsv)
if os.path.isdir(tsvdir) == False: os.mkdir(tsvdir)

#create directory for pickle files after creation
pickledir = os.path.join(processed, pickle)
if os.path.isdir(pickledir) == False: os.mkdir(pickledir)

#create directory for xml files after processing
xmldir = os.path.join(processed, xml)
if os.path.isdir(xmldir) == False: os.mkdir(xmldir)

#list of columns names for tsv and pickle files
columns = [
    'AI_Prov_Name',
    'File_Date',
    'File_Count',
    'Group_Count',
    'Ethnicity',
    'IEP',
    'LEP',
    'Gender',
    'Ven_Stud_ID',
    'Grade',
    'Stud_Test_ID',
    'Score_Flag',
    'Item_ID',
    'Item_Response',
    #*******Scored items********
    'Final_Score',
    'Data_Point',
    'Read1_Date',
    'Read1_ID',
    'Read1_Score',
    'Read1_Cond',
    'Read2_Date',
    'Read2_ID',
    'Read2_Score',
    'Read2_Cond',
    'Read3_Date',
    'Read3_ID',
    'Read3_Score',
    'Read3_Cond',
    'Read5_Date',
    'Read5_ID',
    'Read5_Score',
    'Read5_Cond',
    'Alert_Code',
    'Alert_ReaderID',
    ]

#decompress zip files and move zip files to zip directory
zipfiles = [ f for f in os.listdir(frompems) if f.endswith(".zip") ]

for zfile in zipfiles:
    z = zipfile.ZipFile(os.path.join(frompems,zfile))
    z.extractall(path=frompems)
    z.close()
    shutil.move(os.path.join(frompems,zfile),commdir)


#create list of xml files
xmlfiles = [ f for f in os.listdir(frompems) if f.endswith(".xml") ]


#process the xml files into pickle and tsv files
for xfile in xmlfiles:
    tree = etree.parse(open(os.path.join(frompems,xfile)))
    root = tree.getroot()
    
    data = []    

    for elt in root.getiterator('Item_Details'):
        el_data = {}
        
        el_data['Score_Flag'] = elt.get('Score')
        el_data['Item_ID'] = elt.get('Item_ID')
         
        #ancestor data
        IL = elt.getparent() # Item List
        STD = IL.getparent() # Student_Test_Details
        STL = STD.getparent() # Student_Test_List
        SD = STL.getparent() # Student_Details
        SL = SD.getparent() # Student_List
        GD = SL.getparent() # Group_Details
        GL = GD.getparent() # Group_List
        JD = GL.getparent() # Job_Details
        el_data['Grade'] = STD.get('Grade')
        el_data['Stud_Test_ID'] = STD.get('Student_Test_ID')
        el_data['Ethnicity'] = SD.get("Ethnicity")
        el_data['IEP'] = SD.get("IEP")
        el_data['LEP'] = SD.get("LEP")
        el_data['Gender'] = SD.get("Gender")
        el_data['Ven_Stud_ID'] = SD.get("Vendor_Student_ID")
        el_data['Group_Count'] = GD.get("Case_Count")
        el_data["AI_Prov_Name"] = JD.get("AI_Score_Provider_Name")
        el_data["File_Date"] = JD.get("Date_Time")
        el_data["File_Count"] = JD.get("Case_Count")
        
        #read descendant data
        IR = elt.find('Item_Response')
        el_data['Item_Response'] = IR.text.rstrip()
        
        for child in elt.getiterator('Item_DataPoint_Score_Details'):
            el_data['Final_Score'] = child.get("Final_Score")
            
        for child in elt.getiterator('Score'):
            read = child.get('Read_Number') 
            el_data['Read'+read+'_Date'] = child.get("Date_Time") 
            el_data['Read'+read+'_ID'] = child.get("Reader_ID") 
            el_data['Read'+read+'_Score'] = child.get("Score_Value") 
            el_data['Read'+read+'_Cond'] = child.get("Condition_Code") 

        for child in elt.getiterator('Item_Alert'):
            el_data['Alert_Code'] = child.get("Alert_Code")
            el_data['Alert_ReaderID'] = child.get("Alert_ReaderID")

        #add element data to the file-level data
        data.append(el_data)
        
    #convert into a DataFrame then save as pickle, csv, then move XML to processed directory.
    fileframe = DataFrame(data, columns=columns)
    fileframe.to_pickle(os.path.join(pickledir,os.path.splitext(xfile)[0]+".pickle")) #pickle files useful for further python processing
    fileframe.to_csv(os.path.join(tsvdir,os.path.splitext(xfile)[0]+".tsv"), sep="\t") #tsv filese to be used for R scripts
    shutil.move(os.path.join(frompems,xfile),xmldir)


