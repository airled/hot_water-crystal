///////MAP SCRIPTS SECTION///////
var markers = [];
function initialize(){
	var currentZoom;
	
	if(window.innerHeight < 500){
		currentZoom = 11;
	}
	else if(window.innerHeight > 1200){
		currentZoom = 13;
	}
	else{
		currentZoom = 12;
	}

	var mapOptions = {
		center: {lat: 53.9, lng: 27.55}, 
		zoom: currentZoom,
		disableDefaultUI: true
	};

	var map = new google.maps.Map($("#map-canvas")[0], mapOptions);

	google.maps.event.addListener(map, 'click', function(point) {
		placeMarker(point.latLng, map);
	});
}
function placeMarker(position, map){
	if (markers.length > 0) {
		for (var i = 0; i < markers.length; i++){
	    	markers[i].setMap(null);
	    }
	}
	var marker = new google.maps.Marker({
		position: position,
		map: map,
		title: String(position)
	});
	markers.push(marker);
	visualizePanel();
	setResult(getAddressWithDate(String(position)));
}
google.maps.event.addDomListener(window, 'load', initialize);
///////END OF MAP SCRIPTS SECTION///////

function encode(string){
	return encodeURIComponent(string);
}
function getAddressWithDate(position){
	var geoURL = 'https://geocode-maps.yandex.ru/1.x/?sco=latlong&format=json&geocode=' + String(position).replace(/[\(\) ]/g,'');
	$.ajax({
		url: geoURL,
		datatype: 'json'
	})
	.done(function(data){
		var addressLine = data.response.GeoObjectCollection.featureMember[0].GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AddressLine;
		if(addressLine.split(',').length == 3){
			var city = addressLine.split(',')[0].trim();
			var street = addressLine.split(',')[1].trim();
			var house = addressLine.split(',')[2].trim();
			var dateURL = serverURL + '/date?street=' + encode(street) + '&house=' + encode(house);
			$.ajax({
				url: dateURL,
				async: true,
				datatype: 'json'
			})
			.done(function(data){
				setResult(street + ', ' + house + '<br>' + 'Отключение: ' + JSON.parse(data).date);
			});
		}
		else{
			setResult('Неточный адрес');
		}
	});
}
function findFromForm(){
	var streetForm = $('#form_street').val();
	var houseForm = $('#form_house').val();
	if(streetForm == '' || houseForm == ''){
		setResult('Не введено');
	}
	else if(notValidObject(streetForm) || notValidObject(houseForm)){
		setResult('Неправильный ввод');
	}
	else if(streetForm.length < 3){
		setResult('Слишком короткое название улицы')
	}
	else{
		var dateURL = serverURL + '/date?street=' + encode(streetForm) + '&house=' + encode(houseForm);
		$.ajax({
			url: dateURL,
			datatype: 'json'
		})
		.done(function(data){
			setResult(JSON.parse(data).date);
		});
	}
}
function setResult(result){
	$("#results").html(result);
}
function notValidObject(object){
	if(object.match(/[^А-Яа-я0-9ё\.\ \-]/)){
		return true;
	}
	else{
		return false;
	}
}
function visualizePanel(){
	$("#panel").addClass("visible");
}
$(document).ready(function(){
	$("#form_street").val('');
	$("#form_house").val('');
	$("#form_street").click(visualizePanel);
	$("#form_house").click(visualizePanel);
	$("#form_button").click(visualizePanel);
	$("#form_button").click(findFromForm);
	$("#form_street").autocomplete({
		source: serverURL + '/auto_street'
	});
});
