
{capture name=tabs}
	{if in_array($menu->id, array(12))}
		{if in_array('users', $manager->permissions)}
			<li><a href="index.php?module=UsersAdmin">Guests</a></li>
			<li><a href="index.php?module=MoveInAdmin">Move In</a></li>
			<li><a href="index.php?module=FarewellAdmin">Farewell</a></li>
		{/if}
		{if in_array('issues', $manager->permissions)}<li><a href="index.php?module=IssuesAdmin">Technical Issues</a></li>{/if}
		{if in_array('pages', $manager->permissions)}
			{foreach from=$menus item=m}
				{if in_array("menu_`$m->id`", $manager->permissions) && in_array($m->id, array(12))}
					<li {if $m->id == $menu->id}class="active"{/if}><a href='?module=PagesAdmin&menu_id={$m->id}'>{$m->name}</a></li>
				{/if}
			{/foreach}
		{/if}
	{else}
		{if in_array('pages', $manager->permissions)}
			{foreach from=$menus item=m}
				{if in_array("menu_`$m->id`", $manager->permissions) && !in_array($m->id, array(12))}
					<li {if $m->id == $menu->id}class="active"{/if}><a href='?module=PagesAdmin&menu_id={$m->id}'>{$m->name}</a></li>
				{/if}
			{/foreach}
			<!-- <li><a href="{url module=LoansAdmin menu_id=null}">Вадачи</a></li> -->
		{/if}
		{if in_array('galleries', $manager->permissions)}
			<li><a href="{url module=GalleriesAdmin menu_id=null}">Gallery</a></li>
		{/if}
	{/if}
{/capture}

{if $page->id}
{$meta_title = $page->name scope=parent}
{else}
{$meta_title = 'New page' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}
{literal}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>

<script src="design/js/jquery/datepicker/jquery.ui.datepicker-en.js"></script>

<script src="design/js/jquery/timepicker/jquery-ui-timepicker-addon.js"></script>
<link rel="stylesheet" href="design/js/jquery/timepicker/jquery-ui-timepicker-addon.css">

<script src="design/js/autocomplete/jquery.autocomplete-min.js"></script>
<style>
.autocomplete-suggestions{
background-color: #ffffff;
overflow: hidden;
border: 1px solid #e0e0e0;
overflow-y: auto;
}
.autocomplete-suggestions .autocomplete-suggestion{
	border-bottom: #eee 1px solid;
	cursor: default;
	min-height: 26px;
	padding: 5px 0;
}
.autocomplete-suggestions .selected { background:#F0F0F0; }
.autocomplete-suggestions div { padding:2px 5px; white-space:nowrap; }
.autocomplete-suggestions strong { font-weight:normal; color:#3399FF; }
</style>

<script>
$(function() {


$('input[name="date_modified"]').datetimepicker({
	regional: 'en',
	dateFormat: "yy-mm-dd",
	timeFormat: "HH:mm:ss"
});


	// Сортировка списка
	$(".sortable").sortable({
		items:             ".page_block",
		tolerance:         "pointer",
		handle:            ".move_zone",
		scrollSensitivity: 40,
		opacity:           0.7, 
		//forcePlaceholderSize: true,
		axis: 'y',
	});
	
	// Сортировка изображений
	$(".images ul").sortable({ tolerance: 'pointer'});

	// Удаление изображений
	$(".images a.delete").click( function() {
		$(this).closest('.block.images').find("input[name='delete_image']").val('1');
		$(this).closest('.block.images').find("input[name='delete_bg_image']").val('1');
		$(this).closest("li").fadeOut(200, function() { $(this).remove(); });
		return false;
	});


	// Автозаполнение мета-тегов
	menu_item_name_touched = true;
	meta_title_touched = true;
	meta_keywords_touched = true;
	meta_description_touched = true;
	url_touched = true;
	
	if($('input[name="menu_item_name"]').val() == generate_menu_item_name() || $('input[name="name"]').val() == '')
		menu_item_name_touched = false;
	if($('input[name="meta_title"]').val() == generate_meta_title() || $('input[name="meta_title"]').val() == '')
		meta_title_touched = false;
	if($('input[name="meta_keywords"]').val() == generate_meta_keywords() || $('input[name="meta_keywords"]').val() == '')
		meta_keywords_touched = false;
	if($('textarea[name="meta_description"]').val() == generate_meta_description() || $('textarea[name="meta_description"]').val() == '')
		meta_description_touched = false;
	if($('input[name="url"]').val() == generate_url())
		url_touched = false;
		
	$('input[name="name"]').change(function() { menu_item_name_touched = true; });
	$('input[name="meta_title"]').change(function() { meta_title_touched = true; });
	$('input[name="meta_keywords"]').change(function() { meta_keywords_touched = true; });
	$('textarea[name="meta_description"]').change(function() { meta_description_touched = true; });
	$('input[name="url"]').change(function() { url_touched = true; });
	
	$('input[name="header"]').keyup(function() { set_meta(); });

	// Добавление отзыва
	var new_related_comment = $('#new_related_comment').clone(true);
	$('#new_related_comment').remove().removeAttr('id');
 
	$("input#related_comments").autocomplete({
		serviceUrl:'ajax/search_comments.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				$("input#related_comments").val('').focus().blur(); 
				new_item = new_related_comment.clone().appendTo('.related_comments');
				new_item.removeAttr('id');
				new_item.find('a.related_comment_name').html(suggestion.data.name);
				new_item.find('a.related_comment_name').attr('href', 'index.php?module=PostAdmin&id='+suggestion.data.id);
				new_item.find('input[name*="related"]').val(suggestion.data.id);
				if(suggestion.data.image)
					new_item.find('img.comment_icon').attr("src", suggestion.data.image);
				else
					new_item.find('img.comment_icon').remove();
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return (suggestions.data.image?"<img align=absmiddle src='"+suggestions.data.image+"'> ":'') + suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}

	});

	$(".related_comments a.delete").live('click', function() {
		 $(this).closest("div.row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});

	// Добавление связаного дома
	var new_related_house = $('#new_related_house').clone(true);
	$('#new_related_house').remove().removeAttr('id');
 
	$("input#related_houses").autocomplete({
		serviceUrl:'ajax/search_houses.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				$("input#related_houses").val('').focus().blur(); 
				new_item = new_related_house.clone().appendTo('.related_houses');
				new_item.removeAttr('id');
				new_item.find('a.related_house_name').html(suggestion.data.name);
				new_item.find('a.related_house_name').attr('href', 'index.php?module=PageAdmin&id='+suggestion.data.id);
				new_item.find('input[name*="related_houses"]').val(suggestion.data.id);
				if(suggestion.data.image)
					new_item.find('img.comment_icon').attr("src", suggestion.data.image);
				else
					new_item.find('img.comment_icon').remove();
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return (suggestions.data.image?"<img align=absmiddle src='"+suggestions.data.image+"'> ":'') + suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}

	});

	$(".related_houses a.delete").live('click', function() {
		 $(this).closest("div.row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});

	// Blocks
	var new_page_block = $('.blocks.v1 .hide .page_block').clone(true);
	var block_key = $(new_page_block).find('textarea').attr('data_key');
	$('.blocks.v1 .hide.pb').html('');
	$('.add #add_new_block').live('click', function(){
		block_key = parseInt(block_key, 10) + 1;
		$(new_page_block).find('.backend_inp').attr('name', "blocks[title]["+block_key+"]");
		$(new_page_block).find('select').attr('name', "blocks[type]["+block_key+"]");
		$(new_page_block).find('.upload_image').attr('name', "blocks_images["+block_key+"][]");
		$(new_page_block).find('.editor_small').attr('name', "blocks[body]["+block_key+"]");
		$(new_page_block).clone(true).appendTo('.blocks.v1').fadeIn('slow').find('.clear').empty();
		tiny_init();
		return false;		
	});

	// FAQ
	var new_faq_block = $('.blocks.v2 .hide .page_block').clone(true);
	var faq_key = $(new_faq_block).attr('data_key');
	$('.blocks.v2 .hide.pb').html('');
	$('.add #add_new_faq_block').live('click', function(){
		faq_key = parseInt(faq_key, 10) + 1;
		$(new_faq_block).find('.b_title').attr('name', "faq["+faq_key+"][question]");
		$(new_faq_block).find('.b_description').attr('name', "faq["+faq_key+"][answer]");
		$(new_faq_block).clone(true).appendTo('.blocks.v2 .sortable').fadeIn('slow').find('.clear').empty();
		return false;
	});

	$('.page_block .delete').live('click', function(){
		$(this).closest('.page_block').fadeOut(200, function(){$(this).remove();});
		return false;
	});
});

function set_meta()
{
	if(!menu_item_name_touched)
		$('input[name="name"]').val(generate_menu_item_name());
	if(!meta_title_touched)
		$('input[name="meta_title"]').val(generate_meta_title());
	if(!meta_keywords_touched)
		$('input[name="meta_keywords"]').val(generate_meta_keywords());
	if(!meta_description_touched)
	{
		descr = $('textarea[name="meta_description"]');
		descr.val(generate_meta_description());
		descr.scrollTop(descr.outerHeight());
	}
	if(!url_touched)
		$('input[name="url"]').val(generate_url());
}

function generate_menu_item_name()
{
	name = $('input[name="header"]').val();
	return name;
}

function generate_meta_title()
{
	name = $('input[name="header"]').val();
	return name;
}

function generate_meta_keywords()
{
	name = $('input[name="header"]').val();
	return name;
}

function generate_meta_description()
{
	if(typeof(tinyMCE.get("body")) =='object')
	{
		//description = tinyMCE.get("body").getContent().replace(/(<([^>]+)>)/ig," ").replace(/(\&nbsp;)/ig," ").replace(/^\s+|\s+$/g, '').substr(0, 512);
		//return description;
	}
	else
		return $('textarea[name=body]').val().replace(/(<([^>]+)>)/ig," ").replace(/(\&nbsp;)/ig," ").replace(/^\s+|\s+$/g, '').substr(0, 512);
}

function generate_url()
{
	url = $('input[name="header"]').val();
	url = url.replace(/[\s]+/gi, '-');
	url = translit(url);
	url = url.replace(/[^0-9a-z_\-]+/gi, '').toLowerCase();	
	return url;
}

function translit(str)
{
	var ru=("А-а-Б-б-В-в-Ґ-ґ-Г-г-Д-д-Е-е-Ё-ё-Є-є-Ж-ж-З-з-И-и-І-і-Ї-ї-Й-й-К-к-Л-л-М-м-Н-н-О-о-П-п-Р-р-С-с-Т-т-У-у-Ф-ф-Х-х-Ц-ц-Ч-ч-Ш-ш-Щ-щ-Ъ-ъ-Ы-ы-Ь-ь-Э-э-Ю-ю-Я-я").split("-")   
	var en=("A-a-B-b-V-v-G-g-G-g-D-d-E-e-E-e-E-e-ZH-zh-Z-z-I-i-I-i-I-i-J-j-K-k-L-l-M-m-N-n-O-o-P-p-R-r-S-s-T-t-U-u-F-f-H-h-TS-ts-CH-ch-SH-sh-SCH-sch-'-'-Y-y-'-'-E-e-YU-yu-YA-ya").split("-")   
 	var res = '';
	for(var i=0, l=str.length; i<l; i++)
	{ 
		var s = str.charAt(i), n = ru.indexOf(s); 
		if(n >= 0) { res += en[n]; } 
		else { res += s; } 
    } 
    return res;  
}


</script>


{/literal}


{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">{if $message_success == 'added'}{$page->header|escape} was created{elseif $message_success == 'updated'}{$page->header|escape} was updated{/if}</span>
	<a {if $page->menu_id == 6}style="display: none;"{/if} class="link" target="_blank" href="../{$page->url}">View page</a>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
	
	<span class="share">		
		<a href="#" onClick='window.open("http://vkontakte.ru/share.php?url={$config->root_url|urlencode}/{$page->url|urlencode}&title={$page->name|urlencode}&description={$page->body|urlencode}&noparse=false","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/vk_icon.png" /></a>
		<a href="#" onClick='window.open("http://www.facebook.com/sharer.php?u={$config->root_url|urlencode}/{$page->url|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/facebook_icon.png" /></a>
		<a href="#" onClick='window.open("http://twitter.com/share?text={$page->name|urlencode}&url={$config->root_url|urlencode}/{$page->url|urlencode}&hashtags={$page->meta_keywords|replace:' ':''|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/twitter_icon.png" /></a>
	</span>
	
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error == 'url_exists'}Page with the same URL already exists{/if}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}



<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
	<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=header type="text" value="{$page->header|escape}"/> 
		<input name=id type="hidden" value="{$page->id|escape}"/> 
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $page->visible}checked{/if}/> <label for="active_checkbox">Published</label>
		</div>
		<div class="checkbox">
			<input name=new value='1' type="checkbox" id="new_checkbox" {if $page->new}checked{/if}/> <label for="new_checkbox">New house</label>
		</div>

		<div class="checkbox">
			<input name=coming_soon value='1' type="checkbox" id="coming_soon_checkbox" {if $page->coming_soon}checked{/if}/> <label for="coming_soon_checkbox">Coming soon</label>
		</div>
		<div class="checkbox">
			<input name=featured value='1' type="checkbox" id="featured_checkbox" {if $page->featured}checked{/if}/> <label for="featured_checkbox">Featured</label>
		</div>

		
	</div> 

		

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
    
    	<!-- Параметры страницы -->
		<div class="block">
			<ul>
				<li><label class=property>Menu item name</label><input name="name" class="backend_inp" type="text" value="{$page->name|escape}" /></li>
				{if in_array($page->menu_id, [5])}
					<li>
						<label class=property>NeBo House ID</label>
						<input name="nebo_id" class="backend_inp" type="text" value="{$page->nebo_id|escape}" />
					</li>
				{/if}
				<li><label class=property>Icon<br><a href="http://fontawesome.io/icons/" target="_blank">Font Awesome</a></label><input name="icon" class="backend_inp" type="text" value="{$page->icon|escape}" placeholder="fa-money" /></li>
				<li><label class=property>Menu</label>	
					<select name="menu_id">
				   		{foreach from=$menus item=m}
				   			{if in_array("menu_`$m->id`", $manager->permissions)}
				        	<option value='{$m->id}' {if $page->menu_id == $m->id}selected{/if}>{$m->name|escape}</option>
				        	{/if}
				    	{/foreach}
					</select>		
				</li>
                <li><label class=property>Parent</label>	
                	<select name="parent_id">
                        <option value='0'>Root page</option>
                        {function name=page_select level=0}
                        {foreach from=$cats item=cat}
                            {if $page->id != $cat->id}
                                <option value='{$cat->id}' {if $page->parent_id == $cat->id}selected{/if}>{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;&nbsp;{/section}{$cat->name}</option>
                                {page_select cats=$cat->subcategories level=$level+1}
                            {/if}
                        {/foreach}
                        {/function}
                        {page_select cats=$pages}
                    </select>
                </li>
				{if $page->menu_id == 5}
					<li><label class=property>Neighborhood Group</label>
						<select name="neighborhood">
							<option {if $page->neighborhood == 0}selected{/if} value='0'>Not selected</option>
							<option {if $page->neighborhood == 1}selected{/if} value='1'>Manhattan</option>
							<option {if $page->neighborhood == 2}selected{/if} value='2'>Brooklyn</option>
							<option {if $page->neighborhood == 3}selected{/if} value='3'>Queens</option>
						</select>
					</li>
					<li><label class=property>Neighborhood</label>
						<select name="neighborhood_id">
							<option {if !$page->neighborhood_id}selected{/if} value='0'>Not selected</option>
							{if $neighborhoods}
								{foreach $neighborhoods as $n}
									<option {if $page->neighborhood_id==$n->id}selected{/if} value="{$n->id}">{$n->name|escape}</option>
								{/foreach}
							{/if}
						</select>
					</li>
				{/if}
                <li>
                	<label class=property>Latitude</label><input name="latitude" class="backend_inp" type="text" value="{$page->latitude|escape}" />
                </li>
                <li>
                	<label class=property>Longitude</label><input name="longitude" class="backend_inp" type="text" value="{$page->longitude|escape}" />
                </li>
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->
    
		

		<div class="block layer" {if $page->menu_id == 6 || $page->menu_id == 11 || $page->menu_id == 14}style="display: none;"{/if}>
			<h2>Page properties</h2>
			<ul>
				<li><label class=property>URL</label><div class="page_url">/</div><input name="url" class="page_url" type="text" value="{$page->url|escape}" /></li>
				<li><label class=property>Old url</label><input name="old_url" class="backend_inp" type="text" value="{$page->old_url|escape}" />
				{if $page->old_url}<a href="{$config->root_url}/{$page->old_url|escape}" target="_blank" style="margin:5px 0 10px 170px">Check redirect</a>{/if}
				</li>
				<li><label class=property>Title</label><input name="meta_title" class="backend_inp" type="text" value="{$page->meta_title|escape}" /></li>
				<li><label class=property>Keywords</label><input name="meta_keywords" class="backend_inp" type="text" value="{$page->meta_keywords|escape}" /></li>
				<li><label class=property>Description</label><textarea name="meta_description" class="backend_inp"/>{$page->meta_description|escape}</textarea></li>
			</ul>
		</div>
		
		<div class="block layer">
			<ul>
				<li><label class=property>Date modified</label><input type=text name=date_modified value='{$page->date_modified}'></li>
			</ul>
		</div>
		
		{if $page->menu_id==5}
		<div class="block layer">
			<h2>Application</h2>
			<ul>

				<li>
					<label class=property>Application page</label>
					<select name="applicaation_page_id">
						<option value="0">Not selected</option>
						{foreach $applications_pages as $ap}
							<option value="{$ap->id}"{if $ap->id==$page->applicaation_page_id} selected{/if}>{$ap->header|escape}{if !$ap->visible} [disabled]{/if}</option>
						{/foreach}
					</select>
				</li>
				<li><label class=property>Apply button title</label><input name="apply_name" class="backend_inp" type="text" value="{$page->apply_name|escape}" /></li>
				<p>
					<br>
					<br>
					<strong>Short codes for Page blocks:</strong><br>
					{literal}
					{apply_button}<br>
					{apply_button title="Apply"}
					{/literal}
				</p>
			</ul>
		</div>
		{/if}

			
	</div>
	<!-- Левая колонка свойств страницы  (The End)--> 
    
    <!-- Правая колонка свойств страницы -->	
	<div id="column_right">
	
		<!-- Изображение страницы  -->	
		<div class="block layer images" {if $page->menu_id == 11 || $page->menu_id == 14}style="display: none;"{/if}>
			<h2>Page image</h2>
			<input class='upload_image' name=image type=file>			
			<input type=hidden name="delete_image" value="">
			{if $page->image}
			<ul>
				<li>
					<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
					<img src="../{$config->pages_images_dir}{$page->image}" alt="" />
				</li>
			</ul>
			{/if}
		</div>
		{if in_array($page->menu_id, [5, 16])}
		<!-- бекграунд страницы дома  -->	
		<div class="block layer images">
			<h2>Page background image</h2>
			<input class='upload_image' name=bg_image type=file>			
			<input type=hidden name="delete_bg_image" value="">
			{if $page->bg_image}
			<ul>
				<li>
					<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
					<img src="../{$config->pages_bg_images_dir}{$page->bg_image}" alt="" />
				</li>
			</ul>
			{/if}
		</div>

		<div class="block layer">
			<h2>Reviews</h2>
			<div id=list class="sortable related_comments">
				{if $page->related}
				{foreach $page->related as $related}
				{if $related->type == 2}
				<div class="row">
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=related[] value='{$related->id}'>
					<a href="index.php?module=PostAdmin&id={$related->id}">
					<img class=comment_icon src='{$related->image|resize:blog:35:35}'>
					</a>
					</div>
					<div class="name cell">
					<a href="index.php?module=PostAdmin&id={$related->id}" target="_blank">{$related->name}</a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
				{/if}
				{/foreach}
				{/if}
				<div id="new_related_comment" class="row" style='display:none;'>
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=related[] value=''>
					<img class=comment_icon src=''>
					</div>
					<div class="name cell">
					<a class="related_comment_name" href="" target="_blank"></a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
			</div>
			<input type=text name=search_related id='related_comments' class="input_autocomplete" placeholder='Chose review to add'>
		</div>

		<div class="block layer">
			<h2>Related houses</h2>
			<div id=list class="sortable related_houses">
				{if $page->related_houses}
				{foreach $page->related_houses as $house}
				<div class="row">
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=related_houses[] value='{$house->id}'>
					<a href="index.php?module=PostAdmin&id={$house->id}">
					<img class=comment_icon src='{$house->image|resize:blog:35:35}'>
					</a>
					</div>
					<div class="name cell">
					<a href="index.php?module=PostAdmin&id={$house->id}" target="_blank">{$house->name}</a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
				{/foreach}
				{/if}
				<div id="new_related_house" class="row" style='display:none;'>
					<div class="move cell">
						<div class="move_zone"></div>
					</div>
					<div class="image cell">
					<input type=hidden name=related_houses[] value=''>
					<img class=comment_icon src=''>
					</div>
					<div class="name cell">
					<a class="related_house_name" href="" target="_blank"></a>
					</div>
					<div class="icons cell">
					<a href='#' class="delete"></a>
					</div>
					<div class="clear"></div>
				</div>
			</div>
			<input type=text name=search_related id='related_houses' class="input_autocomplete" placeholder='Chose house to add'>
		</div>

		{/if}
		{if $page->menu_id == 3}
		<div class="block">
			<h2>Use in services</h2>
					<select class=multiple_categories multiple name="services[]">
						{function name=service_select level=0}
                        {foreach from=$cats item=cat}
                                <option value='{$cat->id}' {if $page->service_ids!='' && in_array($cat->id, $page->service_ids)}selected{/if}>{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;&nbsp;{/section}{$cat->name}</option>
                                {service_select cats=$cat->subcategories level=$level+1}
                        {/foreach}
                        {/function}
                        {service_select cats=$services}
					</select>
		</div>
		{/if}
		
	</div>
	<!-- Правая колонка свойств страницы (The End)--> 
    
    
   	<div class="block layer" {if $page->menu_id == 6 || $page->menu_id == 11 || $page->menu_id == 14}style="display: none;"{/if}>
        <h2>Short description</h2>
        <textarea name="annotation"  class="editor_small">{$page->annotation|escape}</textarea>
    </div>
    {if in_array($page->menu_id, [5, 16])}
    <div class="block layer" {if $page->menu_id == 6 || $page->menu_id == 11 || $page->menu_id == 14}style="display: none;"{/if}>
        <h2>Page background text</h2>
        <textarea name="bg_text"  class="editor_small">{$page->bg_text|escape}</textarea>
    </div>
    {/if}
	
	{* Applications*}
	{if $page->menu_id == 15}
	<div class="block layer">
		<h2>Application code</h2>
		<textarea name="body" style="width:100%; height: 400px;">{$page->body}</textarea>
	</div>
	{else}	
	<div class="block layer" {if $page->menu_id == 11 || $page->menu_id == 14}style="display: none;"{/if}>
		<h2>Page text</h2>
		<textarea name="body"{if !in_array($page->id, [475, 476])} class="editor_large"{/if}>{$page->body|escape}</textarea>
	</div>
	
	<div class="block layer" {if $page->menu_id == 11 || $page->menu_id == 14}style="display: none;"{/if}>
		<h2>SEO text</h2>
		<textarea name="body2" class="editor_large">{$page->body2|escape}</textarea>
	</div>
	{/if}

	<!-- House Leader -->
	{if $page->menu_id == 120000}
	<div class="block layer">
		<h2>Page blocks</h2>
		<div class="blocks v1 sortable">
			{$block_key = '0'}
			{if $page->blocks !=""}
			{foreach $page->blocks as $i=>$pb}
				{if $block_key < $i}
					{$block_key = $i}
				{/if}
				<div class="page_block">
					<div class="move_zone"></div>
					<div id="column_left">
						<ul>
							<li><label class=property>Block title</label><input name="blocks[title][{$i}]" class="backend_inp" type="text" value="{$pb->title}" /></li>
							<li><label class=property>Type</label>
								<select name="blocks[type][{$i}]">
									<option value="1" {if $pb->type == '1'}selected{/if}>normal</option>
									<option value="2" {if $pb->type == '2'}selected{/if}>big image</option>
								</select>
							</li>
						</ul>
					</div>
					<div id="column_right">
						<div class="images">
							<h2>Block images</h2>
							<input class='upload_image' multiple name="blocks_images[{$i}][]" type=file>
							<ul>
								{foreach $pb->images as $img}
								<li>
									<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
									<input type="hidden" name="blocks[images][{$i}][]" value="{$img}">
									<img src="../{$config->galleries_images_dir}{$img}" alt="" />									
								</li>
								{/foreach}	
							</ul>
	
						</div>
					</div>
					<div class="block layer">
						<textarea name="blocks[body][{$i}]" class="editor_small">{$pb->body}</textarea>
					</div>
					<span class="icons"><a class="delete" href="#"></a></span>
				</div>
			{/foreach}
			{else}
			<div class="page_block">
				<div class="move_zone"></div>
				<div id="column_left">
					<ul>
						<li>
							<label class=property>Type</label>
								<select name="blocks[type][0]">
									<option value="1" selected>Title</option>
									<option value="2">Description</option>
									<option value="3">Checkbox</option>
								</select>
						</li>

						<li>
							<label class=property>Title</label>
							<input class="backend_inp" name="blocks[title][0]" type="text" value="" />
						</li>

						<li>
							<label class=property>Description</label>
							<textarea class="backend_inp" name="blocks[description][0]"></textarea>
						</li>
						
					</ul>
				</div>
				{*
				<div id="column_right">
					<div class="images">
						<h2>Block images</h2>
						<input class='upload_image' multiple name="blocks_images[0][]" type=file>			
					</div>
				</div>
				<div class="block layer">
					<textarea name="blocks[body][0]" class="editor_small"></textarea>
				</div>
				*}
				<span class="icons"><a class="delete" href="#"></a></span>
			</div>
			{/if}
			<div class="hide pb">
				<div class="page_block">
					<div class="move_zone"></div>
					<div id="column_left">
						<ul>
						<li>
							<label class=property>Type</label>
								<select name="blocks[type][0]">
									<option value="1" selected>Title</option>
									<option value="2">Description</option>
									<option value="3">Checkbox</option>
								</select>
						</li>

						<li>
							<label class=property>Title</label>
							<input class="backend_inp" name="blocks[title][0]" type="text" value="" />
						</li>

						<li>
							<label class=property>Description</label>
							<textarea class="backend_inp" name="blocks[description][0]"></textarea>
						</li>
						
					</ul>
					</div>
					{*
					<div id="column_right">
						<div class="images">
							<h2>Block images</h2>
							<input class='upload_image' data_key="{$block_key}" multiple name="blocks_images[][]" type=file>			
						</div>
					</div>
					<div class="block layer">
						<textarea name="blocks[body][]" data_key="{$block_key}" class="editor_small"></textarea>
					</div>
					*}
					<span class="icons"><a class="delete" href="#"></a></span>
				</div>
			</div>
		</div>
	</div>
	<span class="add"><i class="dash_link" id="add_new_block">Add new block</i></span>
	{/if}


	{if in_array($page->menu_id, [5, 16])}
	<!-- Описание товара (The End)-->
	<div class="block layer">
		<h2>Page blocks</h2>
		<div class="blocks v1 sortable">
			{$block_key = '0'}
			{if $page->blocks !=""}
			{foreach $page->blocks as $i=>$pb}
				{if $block_key < $i}
					{$block_key = $i}
				{/if}
				<div class="page_block">
					<div class="move_zone"></div>
					<div id="column_left">
						<ul>
							<li><label class=property>Block title</label><input name="blocks[title][{$i}]" class="backend_inp" type="text" value="{$pb->title}" /></li>
							<li><label class=property>Type</label>
								<select name="blocks[type][{$i}]">
									<option value="1" {if $pb->type == '1'}selected{/if}>normal</option>
									<option value="2" {if $pb->type == '2'}selected{/if}>big image</option>
								</select>
							</li>
						</ul>
					</div>
					<div id="column_right">
						<div class="images">
							<h2>Block images</h2>
							<input class='upload_image' multiple name="blocks_images[{$i}][]" type=file>
							<ul>
								{foreach $pb->images as $img}
								<li>
									<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
									<input type="hidden" name="blocks[images][{$i}][]" value="{$img}">
									<img src="../{$config->galleries_images_dir}{$img}" alt="" />									
								</li>
								{/foreach}	
							</ul>
	
						</div>
					</div>
					<div class="block layer">
						<textarea name="blocks[body][{$i}]" class="editor_small">{$pb->body}</textarea>
					</div>
					<span class="icons"><a class="delete" href="#"></a></span>
				</div>
			{/foreach}
			{else}
			<div class="page_block">
				<div class="move_zone"></div>
				<div id="column_left">
					<ul>
						<li><label class=property>Block title</label><input name="blocks[title][0]" class="backend_inp" type="text" value="" /></li>
						<li><label class=property>Type</label>
								<select name="blocks[type][0]">
									<option value="1" selected>normal</option>
									<option value="2">big image</option>
								</select>
							</li>
					</ul>
				</div>
				<div id="column_right">
					<div class="images">
						<h2>Block images</h2>
						<input class='upload_image' multiple name="blocks_images[0][]" type=file>			
					</div>
				</div>
				<div class="block layer">
					<textarea name="blocks[body][0]" class="editor_small"></textarea>
				</div>
				<span class="icons"><a class="delete" href="#"></a></span>
			</div>
			{/if}
			<div class="hide pb">
				<div class="page_block">
					<div class="move_zone"></div>
					<div id="column_left">
						<ul>
							<li><label class=property>Block title</label><input name="blocks[title][]" data_key="{$block_key}" class="backend_inp" type="text" value="" /></li>
							<li><label class=property>Type</label>
								<select name="blocks[type][]">
									<option value="1" selected>normal</option>
									<option value="2">big image</option>
								</select>
							</li>
						</ul>
					</div>
					<div id="column_right">
						<div class="images">
							<h2>Block images</h2>
							<input class='upload_image' data_key="{$block_key}" multiple name="blocks_images[][]" type=file>			
						</div>
					</div>
					<div class="block layer">
						<textarea name="blocks[body][]" data_key="{$block_key}" class="editor_small"></textarea>
					</div>
					<span class="icons"><a class="delete" href="#"></a></span>
				</div>
			</div>
		</div>
	</div>
	<span class="add"><i class="dash_link" id="add_new_block">Add new block</i></span>
	<br>
	<!-- Описание -->
	<div class="block layer">
		<h2>Move-in text</h2>
		<textarea name="move_in"  class="editor_large">{$page->move_in|escape}</textarea>
	</div>
	{/if}

	{if $page->menu_id == 11 || $page->menu_id == 14} 
	<!-- hot-deals -->
	<!-- Описание товара (The End)-->
	<div class="block layer">
		<div class="blocks sortable">
			{$block_key = '0'}
			{if $page->blocks !=""}
			{foreach $page->blocks as $i=>$pb}
				{if $block_key < $i}
					{$block_key = $i}
				{/if}
				<div class="page_block">
					<div id="column_left">
						<ul>
							<li><label class=property>Price</label><input name="blocks[price][{$i}]" class="backend_inp" type="text" value="{$pb->price}" /></li>
							<li><label class=property>Starting</label><input name="blocks[move_in][{$i}]" class="backend_inp" type="text" value="{$pb->move_in}" /></li>
							<li><label class=property>Minimal stay</label><input name="blocks[min_stay][{$i}]" class="backend_inp" type="text" value="{$pb->min_stay}" /></li>
							<li><label class=property>Maximum stay</label><input name="blocks[max_stay][{$i}]" class="backend_inp" type="text" value="{$pb->max_stay}" /></li>
							<li><label class=property>Book url</label><input name="blocks[url][{$i}]" class="backend_inp" type="text" value="{$pb->url}" /></li>
						</ul>
					</div>
					<div id="column_right">
						<div class="images">
							<h2>Block images</h2>
							<input class='upload_image' multiple name="blocks_images[{$i}][]" type=file>
							<ul>
								{foreach $pb->images as $img}
								<li>
									<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
									<input type="hidden" name="blocks[images][{$i}][]" value="{$img}">
									<img src="../{$config->galleries_images_dir}{$img}" alt="" />									
								</li>
								{/foreach}	
							</ul>
	
						</div>
					</div>
					<div class="block layer">
						<textarea name="blocks[body][{$i}]" class="editor_small">{$pb->body}</textarea>
					</div>
					<span class="icons"><a class="delete" href="#"></a></span>
				</div>
			{/foreach}
			{else}
			<div class="page_block">
				<div id="column_left">
					<ul>
						<li><label class=property>Price</label><input name="blocks[price][0]" class="backend_inp" type="text" value="" /></li>
						<li><label class=property>Starting</label><input name="blocks[move_in][0]" class="backend_inp" type="text" value="" /></li>
						<li><label class=property>Minimal stay</label><input name="blocks[min_stay][0]" class="backend_inp" type="text" value="" /></li>
						<li><label class=property>Maximum stay</label><input name="blocks[max_stay][0]" class="backend_inp" type="text" value="" /></li>
						<li><label class=property>Book url</label><input name="blocks[url][0]" class="backend_inp" type="text" value="" /></li>
					</ul>
				</div>
				<div id="column_right">
					<div class="images">
						<h2>Block images</h2>
						<input class='upload_image' multiple name="blocks_images[0][]" type=file>			
					</div>
				</div>
				<div class="block layer">
					<textarea name="blocks[body][0]" class="editor_small"></textarea>
				</div>
				<span class="icons"><a class="delete" href="#"></a></span>
			</div>
			{/if}
		</div>
	</div>
	{/if}



	<div class="block layer">
		<h2>FAQ</h2>
		<div class="blocks v2">
			<div class="sortable">
				{$block_key = 0}
				{if $page->blocks2 !=""}
					{foreach $page->blocks2 as $i=>$pb}
						{if $block_key < $i}
							{$block_key = $i}
						{/if}
						<div class="page_block hl_block" data_key="{$block_key}">
							<div class="move_zone"></div>
							<div class="checklist_block">
								<ul>
									<li class="cont">
										<label class=property>Question</label>
										<input name="faq[{$i}][question]" class="backend_inp" type="text" value="{$pb['question']}" />
									</li>
									<li class="cont">
										<label class=property>Текст</label>
										<textarea class="backend_inp" name="faq[{$i}][answer]">{$pb['answer']}</textarea>
									</li>
								</ul>
							</div>
							<span class="icons"><a class="delete" href="#"></a></span>
						</div>
					{/foreach}
				{/if}
			</div><!-- sortable -->

			{foreach $page->blocks2 as $i=>$pb}
				{if $block_key < $i}
					{$block_key = $i}
				{/if}
			{/foreach}
			<div class="hide pb">
				<div class="page_block hl_block" data_key="{$block_key}">
					<div class="move_zone"></div>
					<div class="checklist_block">
						<ul>
							<li class="cont hide">
								<label class=property>Question</label>
								<input class="backend_inp b_title" name="faq[0][question]" type="text" value="">
							</li>
							<li class="cont hide">
								<label class=property>Answer</label>
								<textarea class="backend_inp b_description" name="faq[0][answer]"></textarea>
							</li>
						</ul>
					</div>
					<span class="icons"><a class="delete" href="#"></a></span>
				</div>
			</div>
		</div>
		<span class="add"><i class="dash_link" id="add_new_faq_block">Add</i></span>
	</div>

    
	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->

