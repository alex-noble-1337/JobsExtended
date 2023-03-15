#!/usr/bin/python
from xml.dom import minidom, getDOMImplementation
import base64
import gzip
import sys
import os
import re
import shutil

def dumb_sub_check(file_string):
    file_string = str(file_string)
    extension = file_string[-4] + file_string[-3] + file_string[-2] + file_string[-1]
    if extension == '.sub':
        return True
    else:
        return False
    # return extension == '.sub' and os.path.exists(file_string)

def get_list_of_sub_files_in_dir(sub_files_dir):
    filename_arr = []
    # Get the list of all files and directories
    if(len(sub_files_dir) > 0):
        # TODO make an catch on file not found error
        dir_list = os.listdir(sub_files_dir)
    else:
        dir_list = os.listdir()

    # getting .sub files list
    sub_file_list = []
    for file in dir_list:
        if(len(file)>4):
            if (str(file[-4]) + str(file[-3]) + str(file[-2]) + str(file[-1])) == '.sub':
                sub_file_list.append(file)

    # # testprint TODO make acctual good print of items that get changed
    # for file in sub_file_list:
    #     print(file)
    for file in sub_file_list:
        # append filenames
        filename_arr.append(str(file))
    return filename_arr

def add_by_id(job, waypoints, displacement):
    # job = 'commanding_officer'
    # TODO check if waypoint wint end up in a fucking wall or worse, outside. For now its user problem :barodev:
    x = str(int(waypoints['x']) + displacement)
    y = waypoints['y']
    idcards = waypoints['idcardtags']
    if idcards.find("id_" + job) == -1:
        if len(idcards) > 0:
            idcards += ",id_" + job
        else:
            idcards += "id_" + job
    SpawnPointHuman = {'job': job, 'x': x, 'y': y, 'idcardtags': idcards}
    return SpawnPointHuman

def fileoperation(file_content):
    # parse an xml file by namee)
    with minidom.parseString(file_content) as mydoc:
        # Made this so ppl can se what subs have problems or whatever
        submarine = mydoc.getElementsByTagName('Submarine')[0]
        name = submarine.getAttribute('name')
        print('Submarine name: ' + name)
        #cant print this as variable so whatever
        previewimage = submarine.getAttribute('previewimage')


        # get all waypoints
        waypoints_og = mydoc.getElementsByTagName('WayPoint')
        # remove all occurences of 'newJobs' hope it works
        for elem in waypoints_og:
            if elem.getAttribute("spawn") == "Human":
                if elem.getAttribute('job') in newJobs:
                    mydoc.documentElement.removeChild(elem)
                    elem.unlink()
        waypoints = []
        # add "classes" to 'waypoints' array
        for elem in waypoints_og:
            if elem.getAttribute("spawn") == "Human":
                job = elem.getAttribute('job')
                # initialized first to catch errors later
                x = 0
                y = 0
                idcards = "error"
                if job in vanillaJobs:
                    x = elem.getAttribute('x')
                    y = elem.getAttribute('y')
                    idcardtags = elem.getAttribute('idcardtags')
                    SpawnPointHuman = {
                        'job': job,
                        'x': x,
                        'y': y,
                        'idcardtags': idcardtags
                    }
                    waypoints.append(SpawnPointHuman)
        newwaypoints = []
        if len(waypoints) > 0:
        
            description = submarine.getAttribute('description')
            print('Submarine description: ' + description)
            requiredcontentpackages = submarine.getAttribute('requiredcontentpackages')
            print('Submarine requiredcontentpackages: ' + requiredcontentpackages)

            lastID = 0
            pattern = "(?<=ID=\").*?(?=\")"
            file_forid = str(file_content)
            arrx = re.findall(pattern, file_forid)
            for resoult in arrx:
                if int(resoult) >= lastID:
                    lastID = int(resoult) + 1

            
        
            for i in range(len(waypoints)):
                offset = 40
                # capitan -> co + xo + nav
                if waypoints[i]['job'] == 'captain':
                    # add co spawn from variables - same coordinates as capitan
                    job = 'commanding_officer'
                    newwaypoints.append(add_by_id(job, waypoints[i], 0))
                    # add xo spawn from variables - coordinates from co x=x-2
                    job = 'executive_officer'
                    newwaypoints.append(add_by_id(job, waypoints[i], -offset))
                    # add nav spawn from variables - coordinates from co x=x+2
                    job = 'navigator'
                    newwaypoints.append(add_by_id(job, waypoints[i], offset))
                
                # engineer -> engineering + chief
                if waypoints[i]['job'] == 'engineer':
                    # add engineering spawn from variables - same coordinates as engineer
                    job = 'engineering'
                    newwaypoints.append(add_by_id(job, waypoints[i], 0))
                    # add chief spawn from variables - coordinates from engineering x=x-2
                    job = 'chief'
                    newwaypoints.append(add_by_id(job, waypoints[i], -offset))
                
                # mechanic -> mechanical + quartermaster
                if waypoints[i]['job'] == 'mechanic':
                    # add mechanical spawn from variables - same coordinates as mechanic
                    job = 'mechanical'
                    newwaypoints.append(add_by_id(job, waypoints[i], 0))
                    # add quartermaster spawn from variables - coordinates from mechanical x=x-2
                    job = 'quartermaster'
                    newwaypoints.append(add_by_id(job, waypoints[i], -offset))
                
                # assistant -> passenger + janitor
                if waypoints[i]['job'] == 'assistant':
                    # add passenger spawn from variables - same coordinates as assistant
                    job = 'passenger'
                    newwaypoints.append(add_by_id(job, waypoints[i], 0))
                    # add janitor spawn from variables - coordinates from assistant x=x-2
                    job = 'janitor'
                    newwaypoints.append(add_by_id(job, waypoints[i], -offset))

                # securityofficer -> securityofficer + head_of_security + diver
                if waypoints[i]['job'] == 'securityofficer':
                    # add security spawn from variables - same coordinates as previous
                    job = 'security'
                    newwaypoints.append(add_by_id(job, waypoints[i], 0))
                    # add head_of_security spawn from variables - coordinates from securityofficer x=x-2
                    job = 'head_of_security'
                    newwaypoints.append(add_by_id(job, waypoints[i], -offset))
                    # add diver spawn from variables - coordinates from securityofficer x=x+2
                    job = 'diver'
                    newwaypoints.append(add_by_id(job, waypoints[i], offset))
                
                # medicaldoctor -> medicaldoctor + chiefmedicaldoctor + passenger
                if waypoints[i]['job'] == 'medicaldoctor':
                    # add medicalstaff spawn from variables - same coordinates as previous
                    job = 'medicalstaff'
                    newwaypoints.append(add_by_id(job, waypoints[i], 0))
                    # add chiefmedicaldoctor spawn from variables - coordinates from medicaldoctor x=x-2
                    job = 'chiefmedicaldoctor'
                    newwaypoints.append(add_by_id(job, waypoints[i], -offset))
                    # add passenger spawn from variables - coordinates from medicaldoctor x=x+2
                    job = 'passenger'
                    newwaypoints.append(add_by_id(job, waypoints[i], offset))
        else:
            previewimage = base64.b64decode(previewimage)
            name_ofpic = name + ".png"
            image_result = open(os.path.join(placement_dir, name_ofpic), 'wb')
            print("Item previewimage in a file: " + name_ofpic)
            image_result.write(previewimage)
            return "ERR: No waypoints"

        # testing 'newwaypoints' array
        if verbose == True:
            print('\n')
        for i in range(len(newwaypoints)):
            newWaypoint = mydoc.createElement('WayPoint')
            newWaypoint.setAttribute('ID', str(lastID))
            lastID = 1 + lastID
            newWaypoint.setAttribute('x', str(newwaypoints[i]['x']))
            newWaypoint.setAttribute('y', str(newwaypoints[i]['y']))
            newWaypoint.setAttribute('spawn', "Human")
            newWaypoint.setAttribute('idcardtags', str(newwaypoints[i]['idcardtags']))
            newWaypoint.setAttribute('job', str(newwaypoints[i]['job']))
            # testing 'newwaypoints' array
            if verbose == True:
                print(newWaypoint.toxml())
            mydoc.documentElement.appendChild(newWaypoint)
        if verbose == False:
            print("Waypoints changed: " + str(len(newwaypoints)))

        # change name option
        if changename and name.find(' [JE]') == -1:
            name = name + ' [JE]'
        mydoc.documentElement.setAttribute('name', name)
        # add JobsExtended to requiredcontentpackages
        if requiredcontentpackages.find(', JobsExtended') == -1:
            if len(requiredcontentpackages) > 0:
                requiredcontentpackages += ', ' + name_of_the_mod
            else:
                requiredcontentpackages = "Vanilla" + ', ' + name_of_the_mod
        mydoc.documentElement.setAttribute('requiredcontentpackages', requiredcontentpackages)

        # all items data TESTING
        filenameoutput = name
        tmp_path = os.path.join(placement_dir, os.path.dirname(filenameoutput + ".xml"))
        tmp_file = os.path.join(placement_dir, filenameoutput + ".xml")
        print('All item data in: ' + tmp_file)
        if (os.path.exists(tmp_path) == False):
            os.makedirs(tmp_path)
        xml_result = open(tmp_file, 'w', encoding='utf-8')
        file_string = mydoc.toprettyxml(indent='   ', newl='')
        xml_result.write(file_string)

        if os.path.exists(placement_dir) == False:
            os.mkdir(placement_dir)
            print('Directory ' + placement_dir + ' created')

        previewimage = base64.b64decode(previewimage)
        name_ofpic = name + ".png"
        image_result = open(os.path.join(placement_dir, name_ofpic), 'wb')
        print("Item previewimage in a file: " + name_ofpic + "\n")
        image_result.write(previewimage)

        with open(os.path.join(placement_dir, filenameoutput) + ".xml", 'rb') as f:
            file_content = f.read()
        with gzip.open(os.path.join(placement_dir, filenameoutput) + ".sub", 'wb') as f:
            f.write(file_content)

        return name

# things to import:
# Submarine name

# jobs to replace,  assistant split to other classes and awaiting rework
newJobs = [
    'commanding_officer', 'executive_officer', 'navigator', 'chief',
    'engineering', 'mechanical', 'quartermaster', 'head_of_security',
    'security', 'diver', 'chiefmedicaldoctor', 'medicalstaff', 'passenger',
    'janitor', 'inmate'
]
vanillaJobs = [
    'captain', 'engineer', 'mechanic', 'securityofficer', 'medicaldoctor',
    'assistant'
]

# seeted in main
# filename = "Azimuth [JE].xml"

# # seeted in main
# changename = False

def runit(options_arr_temp):
    global filename
    global changename
    global removeafter
    global placement_dir
    global xml_dir
    global name_of_the_mod
    global filenameoutput
    global verbose

    filenameoutput = ""

    name_of_the_mod = "JobsExtended"
    filename  = "Berilia.sub"
    placement_dir = "placementdir"
    xml_dir = "xmldir"
    sub_files_dir = ""
    changename = False
    removeafter = False
    verbose = False

    filename_arr = []
    options_arr = options_arr_temp
    # DEFAULT OPTIONS
    if(len(options_arr) <= 1): 
        #set up changename
        changename = True
        options_arr.append("-c")

        tempfilename_arr = get_list_of_sub_files_in_dir(sub_files_dir)
        for tempfilename in tempfilename_arr:
            options_arr.append(str(tempfilename))
            filename_arr.append(str(tempfilename))

        # setting up default placement dir 
        options_arr.append("-d")
        options_arr.append(placement_dir)
        placement_dir = "placementdir"


        # filename_arr.append(filename)
    # CUSTOM OPTIONS!
    else:
        for i in range(0,len(options_arr)):

            # -c, --changename option OPTIONAL
            if len(options_arr) >= 1 :
                if options_arr[i] == '--changename' or options_arr[i] == '-c':
                    changename = True
            
            # -r, --remove option OPTIONAL
            if len(options_arr) >= 1 :
                if options_arr[i] == '--remove' or options_arr[i] == '-r':
                    removeafter = True

            # -d, --placementdir + after that specification of placementdir OPTIONAL
            if len(options_arr) >= 1 :
                if options_arr[i-1] == '--placementdir' or options_arr[i-1] == '-d':
                    if len(options_arr) - i > 0:
                        placement_dir = str(options_arr[i]) 
                    continue

            # name of the sub(s) NEEDED
            # IndexError: string index out of range for some thus this:
            if(len(options_arr[i]) > 5):
                if dumb_sub_check(str(options_arr[i])):
                    filename_arr.append(str(options_arr[i]))
                elif(str(options_arr[i][-4]) != "." and str(options_arr[i][-3]) != "." and str(options_arr[i][-2]) != "." and str(options_arr[i][-1]) != "." and os.path.exists(options_arr[i])):
                    tempfilename_arr = get_list_of_sub_files_in_dir(str(options_arr[i]))
                    for tempfilename in tempfilename_arr:
                        if dumb_sub_check(tempfilename):
                            filename_arr.append(os.path.join(str(options_arr[i]), str(tempfilename)))

    # else:
    # TODO a propt for user imput if no arguents are given
    name =""
    if(len(filename_arr) > 0):
        for i in range(len(filename_arr)):
            filename = filename_arr[i]
            old_filename = filename_arr[i]

            if (dumb_sub_check(filename)):
                with gzip.open(filename, 'rb') as f:
                    file_content = f.read()
                    # TODO support for more than one 'filename' or/and detect if user screwed up and typed sub twice. Also less supid check

                    # filename = filename[:-4] + ".xml"
                    # with open(filename, 'wb') as fx:
                    #     fx.write(file_content)

            
                    # filename = os.path.join(placement_dir ,os.path.basename(filename))
                    # xml_dir_filename = os.path.join(xml_dir, filename)

                    name = fileoperation(file_content)
                    if name == "ERR: No waypoints":
                        # skip the cycle
                        print("ERR: No valid waypoints!\n")
                        continue
            # 
            # if os.path.exists(os.path.dirname(os.path.join(xml_dir_filename, (os.path.basename(filename[0:-4]) + " [JE].xml")))) == False:
            #     os.makedirs(xml_dir_filename)
            #     print('Directory ' + os.path.dirname(xml_dir_filename) + ' created')
            # move xml's to xml archive folder

            
            xml_dir_filename = os.path.join(xml_dir, placement_dir)
            filename = os.path.join(os.path.dirname(filename), name[0:-5] + ".sub")


            if(removeafter):
                tmp_input = os.path.join(placement_dir, os.path.basename(filename[0:-4]))
                tmp_output = os.path.join(placement_dir, ".." , "RemoveDir" ,os.path.basename(filename[0:-4]))
                if os.path.exists(os.path.dirname(tmp_output)) == False:
                    os.makedirs(os.path.dirname(tmp_output))
                    print('Directory ' + os.path.dirname(tmp_output) + ' created')
                if os.path.exists(tmp_input + ".sub") == True:
                    shutil.move(tmp_input + ".sub", tmp_output  + ".sub")
                shutil.move(tmp_input + " [JE].xml", tmp_output + " [JE].xml")

def main():
    runit(sys.argv)

if __name__ == '__main__':
    main()
