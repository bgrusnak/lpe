# How to make themes for the LPE

# File format
Theme file is the .zip archive, containing the theme files and manifest. Manifest is the xml file with the name "manifest.xml". During installation of the theme all files from the archive are unpacking to the folder with theme name. 

# Manifest file format
    <?xml version="1.0" encoding="UTF-8" >
    <theme>
        <id>company.themes.id</id>
        <name>THEME NAME</name>
        <version>1.1</version>
        <preview>images/PREVIEW_IMAGE.png</preview>
        <options>
            <group name="sample">
                <option name="testoption" title="TEST OPTION" type="string" order="0">The test option description</option>
                <option name="optionwithoptions" title="DEFAULT" type="string" order="2">The option with degault value
                    <default>default value</default>
                </option>
                <option name="mediaoption" title="Logo" type="media" order="1">Choose the file from the media gallery</option>
          </group>
     </options>
    </theme>