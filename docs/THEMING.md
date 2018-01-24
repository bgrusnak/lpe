# How to make themes for the LPE

# File format
Theme file is the .zip archive, containing the theme files and manifest. Manifest is the xml file with the name "manifest.xml". During installation of the theme all files from the archive are unpacking to the folder with name according to the theme id. 

# Manifest file format
    <?xml version="1.0" encoding="UTF-8" ?>
    <theme>
        <id>theme_id</id>
        <name>THEME NAME</name>
        <version>1.1</version>
        <author>My own name</author>
        <company>Nowhere company</company>
        <url>https://go.to.my.site/my_theme</url>
        <description><![CDATA[
            Here is the long long <i>(~4k)</i> <b>html</b> description you can't read
        ]]></description>
        <preview>images/PREVIEW_IMAGE.png</preview>
        <options>
            <group name="sample" title="Sample options">
                Here is the description of the group
                <option name="testoption" title="TEST OPTION" type="string" order="0">
                    The test option description
                </option>
                <option name="optionwithoptions" title="DEFAULT" type="string" order="2">
                    The option with degault value
                    <default>default value</default>
                </option>
                <option name="mediaoption" title="Logo" type="media" order="1">
                    Choose the file from the media gallery
                </option>
          </group>
     </options>
    </theme>