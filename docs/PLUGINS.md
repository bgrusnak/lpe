# How to make plugins for the LPE

# File format
Plugin file is the .zip archive, containing the plugin files and the manifest. The manifest is an xml file with the name "manifest.xml". During installation of the plugin all files from the archive are unpacking to the folder with name according to the plugin id and group. 
The group usually is the author name, or "default" for the default bundled plugins.  

# Manifest file format
    <?xml version="1.0" encoding="UTF-8" ?>
    <plugin>
        <id>plugin_id</id>
        <group>PLUGIN GROUP</group>
        <name>PLUGIN NAME</name>
        <version>1.1</version>
        <author>My own name</author>
        <company>Nowhere company</company>
        <url>https://go.to.my.site/my_plugin</url>
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
    </plugin>