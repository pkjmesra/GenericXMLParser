An absolutely generic XML parser in Obj-C that parses any xml string and creates runtime objects from the parsed xml. The runtime objects may not be pre-existing.

For an xml :
<?xml version="1.0" encoding="ISO-8859-1"?>

<shiporder orderid="889923"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:noNamespaceSchemaLocation="shiporder.xsd">
	<orderperson>John Smith</orderperson>
	<shipto itemType="Iron">
		<name>Ola Nordmann</name>
		<address>Langgt 23</address>
		<city>4000 Stavanger</city>
		<country>Norway</country>
	</shipto>
	<item>
		<title>Empire Burlesque</title>
		<note>Special Edition</note>
		<quantity>1</quantity>
		<price>10.90</price>
	</item>
	<item>
		<title>Hide your heart</title>
		<title>Another Title</title>
		<quantity>1</quantity>
		<quantity>another quantity value</quantity>
		<price>9.90</price>
	</item>
</shiporder>

an object graph like this is generated:

{
    "shiporder.attributes.noNamespaceSchemaLocation" = "shiporder.xsd";		<--Mark it here. The attributes would be specially marked with a prefix.


    "shiporder.attributes.orderid" = 889923;
    "shiporder.item" = "<item 0x4e615a0: iVarCount=5 >";
    "shiporder.item.note" = "<note 0x4e61fa0: iVarCount=2 >";
    "shiporder.item.note.innerValue" = "Special Edition";
    "shiporder.item.note.parentInstance" = "<item 0x4e615a0: iVarCount=5 >";	<--Mark it here. The parentInstance will give you access to root level object.


    "shiporder.item.parentInstance" = "<shiporder 0x4e60050: iVarCount=6 >";
    "shiporder.item.price" = "<price 0x4e637a0: iVarCount=2 >";
    "shiporder.item.price.innerValue" = "10.90";				<--Mark it here. The innerValue would give you the content value for a node.
    "shiporder.item.price.parentInstance" = "<item 0x4e615a0: iVarCount=5 >";


    "shiporder.item.quantity" = "<quantity 0x4e64390: iVarCount=2 >";
    "shiporder.item.quantity.innerValue" = 1;
    "shiporder.item.quantity.parentInstance" = "<item 0x4e615a0: iVarCount=5 >";
    "shiporder.item.title" = "<title 0x4e62b90: iVarCount=2 >";
    "shiporder.item.title.innerValue" = "Empire Burlesque";
    "shiporder.item.title.parentInstance" = "<item 0x4e615a0: iVarCount=5 >";
    "shiporder.item1" = "<item1 0x4e6aff0: iVarCount=6 >";			<--Mark it here. The duplicate nodes will be renamed sequentially -- item, item1, item2 etc.


    "shiporder.item1.parentInstance" = "<shiporder 0x4e60050: iVarCount=6 >";
    "shiporder.item1.price" = "<price 0x4e6c530: iVarCount=2 >";
    "shiporder.item1.price.innerValue" = "9.90";
    "shiporder.item1.price.parentInstance" = "<item1 0x4e6aff0: iVarCount=6 >";
    "shiporder.item1.quantity" = "<quantity 0x4e6cb20: iVarCount=2 >";
    "shiporder.item1.quantity.innerValue" = 1;
    "shiporder.item1.quantity.parentInstance" = "<item1 0x4e6aff0: iVarCount=6 >";
    "shiporder.item1.quantity1" = "<quantity1 0x4e6c010: iVarCount=2 >";
    "shiporder.item1.quantity1.innerValue" = "another quantity value";
    "shiporder.item1.quantity1.parentInstance" = "<item1 0x4e6aff0: iVarCount=6 >";	<--Mark it here. The duplicate nodes and subnodes
 will be renamed sequentially -- item, item1, item2 etc and quantity, quantity1, quantity2 etc.

    "shiporder.item1.title" = "<title 0x4e6b440: iVarCount=2 >";
    "shiporder.item1.title.innerValue" = "Hide your heart";
    "shiporder.item1.title.parentInstance" = "<item1 0x4e6aff0: iVarCount=6 >";
    "shiporder.item1.title1" = "<title1 0x4e6d6f0: iVarCount=2 >";
    "shiporder.item1.title1.innerValue" = "Another Title";
    "shiporder.item1.title1.parentInstance" = "<item1 0x4e6aff0: iVarCount=6 >";
    "shiporder.orderperson" = "<orderperson 0x4e69960: iVarCount=2 >";
    "shiporder.orderperson.innerValue" = "John Smith";
    "shiporder.orderperson.parentInstance" = "<shiporder 0x4e60050: iVarCount=6 >";
    "shiporder.shipto" = "<shipto 0x4e65ae0: iVarCount=6 >";
    "shiporder.shipto.address" = "<address 0x4e68bb0: iVarCount=2 >";
    "shiporder.shipto.address.innerValue" = "Langgt 23";
    "shiporder.shipto.address.parentInstance" = "<shipto 0x4e65ae0: iVarCount=6 >";
    "shiporder.shipto.attributes.itemType" = Iron;					<--Mark it here. The attributes would be specially marked with a prefix.


    "shiporder.shipto.city" = "<city 0x4e67fa0: iVarCount=2 >";
    "shiporder.shipto.city.innerValue" = "4000 Stavanger";
    "shiporder.shipto.city.parentInstance" = "<shipto 0x4e65ae0: iVarCount=6 >";
    "shiporder.shipto.country" = "<country 0x4e67360: iVarCount=2 >";
    "shiporder.shipto.country.innerValue" = Norway;
    "shiporder.shipto.country.parentInstance" = "<shipto 0x4e65ae0: iVarCount=6 >";
    "shiporder.shipto.name" = "<name 0x4e666c0: iVarCount=2 >";
    "shiporder.shipto.name.innerValue" = "Ola Nordmann";
    "shiporder.shipto.name.parentInstance" = "<shipto 0x4e65ae0: iVarCount=6 >";
    "shiporder.shipto.parentInstance" = "<shiporder 0x4e60050: iVarCount=6 >";
}