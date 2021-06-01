#!/usr/bin/perl

use Data::Dumper;
use JSON::XS;

open(TSV,"learning-providers-plus.tsv");
@lines = <TSV>;
close(TSV);

$data;
#UKPRN	PROVIDER_NAME	VIEW_NAME	SORT_NAME	ALIAS	FLAT_NAME_NUMBER	BUILDING_NAME_NUMBER	LOCALITY	STREET_NAME	TOWN	POSTCODE	WEBSITE_URL	WIKIPEDIA_URL	GROUPS	LONGITUDE	LATITUDE	EASTING	NORTHING	GTR_ID	HESA_ID
for($i = 1; $i < @lines; $i++){
	(@cols) = split("\t",$lines[$i]);
	$ukprn = $cols[0];
	if(!$data->{'orgs'}){
		$data->{'orgs'} = {};
	}
	if(!$data->{'orgs'}{$ukprn}){
		$data->{'orgs'}{$ukprn} = {'name'=>$cols[2],'urls'=>{}};
	}
	$data->{'orgs'}{$ukprn}{'urls'}{$cols[11]} = {'values'=>{}};
}

saveIndex();




##################################################
# SUBROUTINES
sub saveIndex {
	my ($str,$date,$contents,$newcontent);

	$str = JSON::XS->new->utf8->pretty(1)->canonical(1)->encode($data);
	$str =~ s/   /\t/g;
	$str =~ s/ \: /: /g;
	$str =~ s/\n\t+"date"\: "([^\"]*)"\,\n\t+"id"\: "([^\"]*)"\n\t+/ "date": "$1", "id": "$2" /g;
	while($str =~ /"([0-9]{4}-[0-9]{2}-[0-9]{2})": \{\n([^\}]*?)\}/){
		$date = $1;
		$contents = $2;
		$newcontent = "\n".$contents;
		$newcontent =~ s/\n\t+/ /g;
		# Replace
		$str =~ s/"$date": \{\n$contents\}/"$date": \{$newcontent\}/;
	}
	$str =~ s/\n\t+"CO2"\: ([^\,]*)\,\n\t+"ref"\: "([^\"]*)"\n\t+/"CO2": $1, "ref": "$2"/g;

	open(FILE,">","index.json");
	print FILE $str;
	close(FILE);

	return;
}

#{
#	"orgs": {
#		"95ZZ": {
#			"active": false,
#			"name": "Strabane District Council",
#			"replacedBy": { "date": "2015-04-01", "id": "N09000005" },
#			"urls": {
#				"http://www.strabanedc.org.uk/": {
#					"values": {
#						"2021-03-04": { "CO2": 1.84, "ref": "https://www.websitecarbon.com/website/strabanedc-org-uk/" },
#						"2021-05-27": { "CO2": 1.83, "bytes": 3042390, "green": 0, "imagebytes": 2020536 }
#					}
#				}
#			}
#		},