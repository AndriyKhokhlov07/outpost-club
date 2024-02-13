{capture name=tabs}
	<li class="active"><a href="?module=GalleriesAdmin">Galleries</a></li>
{/capture}

{if $gallery->id}
	{$meta_title = $gallery->name scope=parent}
{else}
	{$meta_title = 'New gallery' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}
{literal}
<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>


<script>
$(function() {
	
	
	// Добавление категории
	$('#product_categories .add').click(function() {
		$("#product_categories ul li:last").clone(false).appendTo('#product_categories ul').fadeIn('slow').find("select[name*=categories]:last").focus();
		$("#product_categories ul li:last span.add").hide();
		$("#product_categories ul li:last span.delete").show();
		return false;		
	});

	// Удаление категории
	$("#product_categories .delete").live('click', function() {
		$(this).closest("li").fadeOut(200, function() { $(this).remove(); });
		return false;
	});
	
	$('.show_settings').click(function(){
		$(this).hide();
		$('.settings_block').slideDown();
	});

	// Автозаполнение мета-тегов
	menu_item_name_touched = true;
	meta_title_touched = true;
	meta_keywords_touched = true;
	meta_description_touched = true;
	url_touched = true;
	
	/*if($('input[name="menu_item_name"]').val() == generate_menu_item_name() || $('input[name="name"]').val() == '')
		menu_item_name_touched = false;*/
	if($('input[name="meta_title"]').val() == generate_meta_title() || $('input[name="meta_title"]').val() == '')
		meta_title_touched = false;
	if($('input[name="meta_keywords"]').val() == generate_meta_keywords() || $('input[name="meta_keywords"]').val() == '')
		meta_keywords_touched = false;
	if($('textarea[name="meta_description"]').val() == generate_meta_description() || $('textarea[name="meta_description"]').val() == '')
		meta_description_touched = false;
	if($('input[name="url"]').val() == generate_url())
		url_touched = false;
		
	$('input[name="meta_title"]').change(function() { meta_title_touched = true; });
	$('input[name="meta_keywords"]').change(function() { meta_keywords_touched = true; });
	$('textarea[name="meta_description"]').change(function() { meta_description_touched = true; });
	$('input[name="url"]').change(function() { url_touched = true; });
	
	$('input[name="name"]').keyup(function() { set_meta(); });
	
	
	
	// Раскраска строк
	function colorize()
	{
		$("#list div.row:even").addClass('even');
		$("#list div.row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();
	
	
	// Сортировка списка
	$(".sortable").sortable({
		items: "div.row",
		tolerance:"pointer",
		scrollSensitivity:40,
		opacity:0.7,
		handle: '.move_zone'
	});
	
	// Сделать изображение главным
	$("a.featured").click(function() {
		var icon        = $(this);
		var line        = icon.closest("div.row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('featured')?0:1;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'image', 'id': id, 'values': {'main': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
			success: function(data){
				icon.removeClass('loading_icon');
				if(state)
					line.addClass('featured');				
				else
					line.removeClass('featured');
			},
			dataType: 'json'
		});	
		return false;	
	});

	
	// Удалить 
	$(".images_gallery a.delete").click(function() {
		$('#listinput[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});
	
	
	$("form").submit(function() {
		if($('select[name="action"]').val()=='delete' && !confirm('Please, confirm deletion'))
			return false;	
	});
	
	
	
	
});

function set_meta()
{
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

function generate_meta_title()
{
	name = $('input[name="name"]').val();
	return name;
}

function generate_meta_keywords()
{
	name = $('input[name="name"]').val();
	return name;
}

function generate_meta_description()
{
	if(typeof(tinyMCE.get("body")) =='object')
	{
		description = tinyMCE.get("body").getContent().replace(/(<([^>]+)>)/ig," ").replace(/(\&nbsp;)/ig," ").replace(/^\s+|\s+$/g, '').substr(0, 512);
		return description;
	}
	else
		return $('textarea[name=body]').val().replace(/(<([^>]+)>)/ig," ").replace(/(\&nbsp;)/ig," ").replace(/^\s+|\s+$/g, '').substr(0, 512);
}

function generate_url()
{
	url = $('input[name="name"]').val();
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
	<span class="text">{if $message_success == 'added'}Gallery added{elseif $message_success == 'updated'}Gallery updated{/if}</span>
	<a class="link" target="_blank" href="../gallery/{$gallery->url}">Open the gallery on the site</a>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
	
    {*
	<span class="share">		
		<a href="#" onClick='window.open("http://vkontakte.ru/share.php?url={$config->root_url|urlencode}/{$gallery->url|urlencode}&title={$gallery->name|urlencode}&description={$gallery->body|urlencode}&noparse=false","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/vk_icon.png" /></a>
		<a href="#" onClick='window.open("http://www.facebook.com/sharer.php?u={$config->root_url|urlencode}/{$gallery->url|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/facebook_icon.png" /></a>
		<a href="#" onClick='window.open("http://twitter.com/share?text={$gallery->name|urlencode}&url={$config->root_url|urlencode}/{$gallery->url|urlencode}&hashtags={$gallery->meta_keywords|replace:' ':''|urlencode}","displayWindow","width=700,height=400,left=250,top=170,status=no,toolbar=no,menubar=no");return false;'>
  		<img src="{$config->root_url}/backend/design/images/twitter_icon.png" /></a>
	</span>
    *}
	
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error == 'url_exists'}A gallery with this url already exists{/if}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}



<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
	<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$gallery->name|escape}"/> 
		<input name=id type="hidden" value="{$gallery->id|escape}"/> 
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $gallery->visible}checked{/if}/> <label for="active_checkbox">Published</label>
		</div>
	</div> 
    {if $gallery->id}
    	<div class="show_settings">Show gallery options</div>
    {/if}
    
    <div class="settings_block"{if $gallery->id} style="display:none"{/if}>
	<div id="product_categories" {if !$categories}style='display:none;'{/if}>
		<label>Category</label>
		<div>
			<ul>
				{foreach name=categories from=$gallery_categories item=gallery_category}
				<li>
					<select name="categories[]">
						{function name=category_select level=0}
						{foreach from=$categories item=category}
								<option value='{$category->id}' {if $category->id == $selected_id}selected{/if} category_name='{$category->name|escape}'>{section name=sp loop=$level}&nbsp;&nbsp;&nbsp;&nbsp;{/section}{$category->name|escape}</option>
								{category_select categories=$category->subcategories selected_id=$selected_id  level=$level+1}
						{/foreach}
						{/function}
						{category_select categories=$categories selected_id=$gallery_category->category_id}
					</select>
					<span {if not $smarty.foreach.categories.first}style='display:none;'{/if} class="add"><i class="dash_link">Additional category</i></span>
					<span {if $smarty.foreach.categories.first}style='display:none;'{/if} class="delete"><i class="dash_link">Delete</i></span>
				</li>
				{/foreach}		
			</ul>
		</div>
	</div>

	

	<!-- Левая колонка свойств товара -->
	<div id="column_left">
			
		<!-- Параметры страницы -->
		<div class="block layer">
			<h2>Page properties</h2>
			<ul>
				<li><label class=property>URL</label><div class="page_url">gallery/</div><input name="url" class="page_url" type="text" value="{$gallery->url|escape}" /></li>
				<li><label class=property>Title</label><input name="meta_title" class="backend_inp" type="text" value="{$gallery->meta_title|escape}" /></li>
				<li><label class=property>Keywords</label><input name="meta_keywords" class="backend_inp" type="text" value="{$gallery->meta_keywords|escape}" /></li>
				<li><label class=property>Description</label><textarea name="meta_description" class="backend_inp">{$gallery->meta_description|escape}</textarea></li>
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->		

			
	</div>
	<!-- Левая колонка свойств товара (The End)--> 
    
	
    <div class="block layer">
		<h2>Annotation</h2>
		<textarea name="annotation" class="editor_small">{$gallery->annotation|escape}</textarea>
	</div>
    	
	<!-- Описагние -->
	<div class="block layer">
		<h2>Text</h2>
		<textarea name="body"  class="editor_small">{$gallery->body|escape}</textarea>
	</div>
	<!-- Описание (The End)-->
   
    </div>
    
	<input class="button_green button_save" type="submit" name="" value="Save" />
    
    {if $gallery->id}
    <div class="block layer">
    
    	<div id="header">
            <h1>Images</h1>
            <a class="add" href="{url module=ImageGalleryAdmin id=null gallery_id=$gallery->id}">Add image</a>
        </div>
        
        {if $images}
        <div id="main_list">
        	<div id="list" class="sortable images_gallery">
            	{foreach $images as $image}
                	<div class="{if !$image->visible}invisible{/if} {if $image->main}featured{/if} row">
                        <input type="hidden" name="positions[{$image->id}]" value="{$image->position}">
                        <div class="move cell"><div class="move_zone"></div></div>
                        <div class="checkbox cell">
                            <input type="checkbox" name="check[]" value="{$image->id}" />				
                        </div>
                        <div class="image cell">
                        {if $image->filename}
                        	<a href="{url module=ImageGalleryAdmin id=$image->id gallery_id=$gallery->id return=$smarty.server.REQUEST_URI}"><img src="{$image->filename|resize:gallery:120:120}" /></a>
                        {/if}
                        </div>
                        <div class="name cell">
                            <a href="{url module=ImageGalleryAdmin id=$image->id gallery_id=$gallery->id return=$smarty.server.REQUEST_URI}">{$image->name|escape}</a>
                        </div>
                        <div class="icons cell">
                            <a class="featured"  title="Main image" href="#"></a>
                            <a class="delete" title="Delete" href="#"></a>
                        </div>
                        <div class="clear"></div>
                    </div>
                {/foreach}
            </div>
        </div>
        {/if}
    </div>
    
	<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id="select">
		<select name="action">
        	<option value="">Select an action</option>
			<option value="delete">Delete</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
	
	</div>
    
    
    {/if}
	
</form>
<!-- Основная форма (The End) -->

