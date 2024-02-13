
{capture name=tabs}
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

	// Добавление нового значения свойства товара
	var new_page_block = $('.blocks .hide .page_block').clone(true);
	var block_key = $(new_page_block).attr('data_key');
	$('.blocks .hide.pb').html('');
	$('.add #add_new_block').live('click', function(){
		block_key = parseInt(block_key, 10) + 1;		
		$(new_page_block).find('.b_title').attr('name', "b["+block_key+"][title]");
		$(new_page_block).find('.b_type').attr('name', "b["+block_key+"][type]");
		$(new_page_block).find('.b_description').attr('name', "b["+block_key+"][description]");

		$(new_page_block).find('.subblocks').attr('sn', "b["+block_key+"]");
		$(new_page_block).clone(true).appendTo('.blocks').fadeIn('slow').find('.clear').empty();
		return false;		
	});

	$('.add #add_new_subblock').live('click', function(){
		var subblocks = $(this).closest('.subblocks');
		var skey = parseInt(subblocks.attr('data_skey'), 10) + 1;
		subblocks.attr('data_skey', skey);

		$(new_page_block).find('.b_title').attr('name', subblocks.attr('sn')+'[sub]['+skey+'][title]');
		$(new_page_block).find('.b_type').attr('name', subblocks.attr('sn')+'[sub]['+skey+'][type]');
		$(new_page_block).find('.b_description').attr('name', subblocks.attr('sn')+'[sub]['+skey+'][description]');

		$(new_page_block).find('.subblocks').attr('sn', subblocks.attr('sn')+'[sub]['+skey+']');

		$(new_page_block).clone(true).appendTo(subblocks.find('>.wrapper')).fadeIn('slow').find('.clear').empty();
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
	</div> 

		

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
    
    	<!-- Параметры страницы -->
		<div class="block">
			<ul>
				<li><label class=property>Menu item name</label><input name="name" class="backend_inp" type="text" value="{$page->name|escape}" /></li>
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
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->
    
			
		<!-- Параметры страницы -->
		<div class="block layer" {if $page->menu_id == 6 || $page->menu_id == 11}style="display: none;"{/if}>
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
		<!-- Параметры страницы (The End)-->		

			
	</div>
	<!-- Левая колонка свойств страницы  (The End)--> 
    
    <!-- Правая колонка свойств страницы -->	
	<div id="column_right">
	
		<!-- Изображение страницы  -->	
		<div class="block layer images" {if $page->menu_id == 11}style="display: none;"{/if}>
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
		{if $page->menu_id == 5}
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
    
    
   	<div class="block layer" {if $page->menu_id == 6 || $page->menu_id == 11}style="display: none;"{/if}>
        <h2>Short description</h2>
        <textarea name="annotation"  class="editor_small">{$page->annotation|escape}</textarea>
    </div>
    {if $page->menu_id == 5}
    <div class="block layer" {if $page->menu_id == 6 || $page->menu_id == 11}style="display: none;"{/if}>
        <h2>Page background text</h2>
        <textarea name="bg_text"  class="editor_small">{$page->bg_text|escape}</textarea>
    </div>
    {/if}
		
		
	<!-- Описание -->
	<div class="block layer" {if $page->menu_id == 11}style="display: none;"{/if}>
		<h2>Page text</h2>
		<textarea name="body"  class="editor_large">{$page->body|escape}</textarea>
	</div>

	<!-- House Leader -->
	{if $page->menu_id == 12}
	<div class="block layer">
		<h2>Checklist</h2>
		<div class="blocks">



			{$block_key = 0}
			{if $page->blocks !=""}
				{function name=page_blocks_tree sn='b'}
					{if $page_blocks}
					<div class="sortable">
					{foreach $page_blocks as $i=>$pb}
						{if $block_key < $i}
							{$block_key = $i}
						{/if}
						<div class="page_block hl_block" data_key="{$block_key}">
							<div class="move_zone"></div>
							<div class="checklist_block">
								<ul>
									<li>
										<label class=property>Type</label>
										<select name="{$sn}[{$i}][type]">
											<option value="1" {if $pb['type'] == '1'}selected{/if}>Text</option>
											<option value="2" {if $pb['type'] == '2'}selected{/if}>Checkbox</option>
											<option value="3" {if $pb['type'] == '3'}selected{/if}>Radiobutton</option>
											<option value="4" {if $pb['type'] == '4'}selected{/if}>Title Radiobutton</option>
											<option value="5" {if $pb['type'] == '5'}selected{/if}>Input</option>
											<option value="6" {if $pb['type'] == '6'}selected{/if}>Textarea</option>
											<option value="7" {if $pb['type'] == '7'}selected{/if}>Note</option>
											<option value="8" {if $pb['type'] == '8'}selected{/if}>Select house</option>
											<option value="9" {if $pb['type'] == '9'}selected{/if}>Restocking items</option>
											<option value="10" {if $pb['type'] == '10'}selected{/if}>Notification email</option>
											<option value="11" {if $pb['type'] == '11'}selected{/if}>Upload file</option>
										</select>
										{if in_array($pb['type'], array(2,3)) && $pb['sub']}
											<label style="white-space:nowrap">
												<input type="checkbox" name="{$sn}[{$i}][hide_child]" {if $pb['hide_child'] == '1'}checked{/if} value="1"> If not selected, hide children
											</label>
										{/if}
									</li>



									<li>
										<label class=property>Title</label>
										<input name="{$sn}[{$i}][title]" class="backend_inp" type="text" value="{$pb['title']}" /></li>
									<li>
										<label class=property>Description</label>
										<textarea class="backend_inp" name="{$sn}[{$i}][description]">{$pb['description']}</textarea>
									</li>
								</ul>
							</div>
							{$skey = 0}
							{if $pb['sub']}
								{foreach $pb['sub'] as $si=>$sb}
									{if $skey < $si}
										{$skey = $si}
									{/if}
								{/foreach}
							{/if}
							<div class="subblocks" data_skey="{$skey}" sn="{$sn}[{$i}]">
								<div class="wrapper">
									{if $pb['sub']}
										{page_blocks_tree page_blocks=$pb['sub'] sn="{$sn}[{$i}][sub]"}
									{/if}
								</div>
								<span class="add"><i class="dash_link" id="add_new_subblock">Add block</i></span>
							</div><!-- subblocks -->
							<span class="icons"><a class="delete" href="#"></a></span>
						</div>
					{/foreach}
					</div><!-- sortable -->
					{/if}
				{/function}
				{page_blocks_tree page_blocks=$page->blocks sn='b'}
			{else}
			{*
			<div class="page_block hl_block">
				<div class="move_zone"></div>
				<div id="column_left">
					<ul>
						<li>
							<label class=property>Type</label>
							<select name="b[0][type]">
								<option value="1" selected>Text</option>
								<option value="2">Checkbox</option>
								<option value="3">Radiobutton</option>
								<option value="4">Title Radiobutton</option>
								<option value="5">Input</option>
								<option value="6">Textarea</option>
								<option value="7">Note</option>
								<option value="8">Select house</option>
								<option value="9">Restocking items</option>
								<option value="10">Notification email</option>
								<option value="11">Upload file</option>
							</select>
						</li>

						<li>
							<label class=property>Title</label>
							<input class="backend_inp" name="b[0][title]" type="text" value="" />
						</li>

						<li>
							<label class=property>Description</label>
							<textarea class="backend_inp" name="b[0][description]"></textarea>
						</li>
						
					</ul>
				</div>
				<div class="subblocks" data_skey="0">
					<div class="wrapper"></div>
					<span class="add"><i class="dash_link" id="add_new_subblock">Add block</i></span>
				</div><!-- subblocks -->
				<span class="icons"><a class="delete" href="#"></a></span>
			</div>
			*}
			{/if}

			{foreach $page->blocks as $i=>$pb}
				{if $block_key < $i}
					{$block_key = $i}
				{/if}
			{/foreach}
			<div class="hide pb">
				<div class="page_block hl_block" data_key="{$block_key}">
					<div class="move_zone"></div>
					<div class="checklist_block">
						<ul>
							<li>
								<label class=property>Type</label>
								<select class="b_type" name="b[0][type]">
									<option value="1" selected>Text</option>
									<option value="2">Checkbox</option>
									<option value="3">Radiobutton</option>
									<option value="4">Title Radiobutton</option>
									<option value="5">Input</option>
									<option value="6">Textarea</option>
									<option value="7">Note</option>
									<option value="8">Select house</option>
									<option value="9">Restocking items</option>
									<option value="10">Notification email</option>
									<option value="11">Upload file</option>
								</select>
							</li>

							<li>
								<label class=property>Title</label>
								<input class="backend_inp b_title" name="b[0][title]" type="text" value="" />
							</li>

							<li>
								<label class=property>Description</label>
								<textarea class="backend_inp b_description" name="b[0][description]"></textarea>
							</li>
							
						</ul>
					</div>
					<div class="subblocks" data_skey="0">
						<div class="wrapper"></div>
						<span class="add"><i class="dash_link" id="add_new_subblock">Add block</i></span>
					</div><!-- subblocks -->

					<span class="icons"><a class="delete" href="#"></a></span>
				</div>
			</div>
		</div>
		<span class="add"><i class="dash_link" id="add_new_block">Add block</i></span>
	</div>
	
	{/if}


	<input class="button_green button_save" type="submit" name="" value="Save" />
	
</form>
<!-- Основная форма (The End) -->

