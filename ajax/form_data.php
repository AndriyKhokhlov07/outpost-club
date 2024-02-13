<?
chdir('..');
require_once('api/Backend.php');
$backend = new Backend();

$type = $backend->request->post('type', 'string');

$form_data = array();

if(!empty($type)){
	if(in_array($type, array('kvart', 'dom', 'nejil', 'zalog_nedvij'))){
		$form_data = array(
			'г. Киев',
			'Киевская область',
			'г. Днепр', 
			'г. Винница', 
			'г. Житомир', 
			'г. Львов', 
			'г. Одесса', 
			'г. Ровно', 
			'г. Харьков', 
			'г. Хмельницкий'
		);
	}
	elseif(in_array($type, array('uchast', 'nedostr', 'pokup_nedvij', 'bezzal', 'vykup_nedvij'))){
		$form_data = array(
			'г. Киев',
			'Киевская область'
		);
	}
	elseif(in_array($type, array('avto'))){
		$form_data = array(
			'г. Киев',
	        'Винницкая область',
	        'Волынская область',
	        'Днепропетровская область',
	        'Донецкая область',
	        'Житомирская область',
	        'Закарпатская область',
	        'Запорожская область',
	        'Ивано-Франковская область',
	        'Киевская область',
	        'Кировоградская область',
	        'Луганская область',
	        'Львовская область',
	        'Николаевская область',
	        'Одесская область',
	        'Полтавская область',
	        'Ровненская область',
	        'Сумская область',
	        'Тернопольская область',
	        'Харьковская область',
	        'Херсонская область',
	        'Хмельницкая область',
	        'Черкасская область',
	        'Черниговская область',
	        'Черновицкая область'		
	    );
	}
}
$results = $form_data;

	
header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");
echo json_encode($results);
