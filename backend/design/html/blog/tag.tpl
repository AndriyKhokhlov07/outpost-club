{* Вкладки *}
{capture name=tabs}
	<li><a href="index.php?module=BlogAdmin&type=1">Blog</a></li>
	<!-- <li {if $type==2} class="active" {/if}><a href="index.php?module=BlogAdmin&type=2">Reviews</a></li> -->
	<li><a href="index.php?module=AuthorsAdmin">Authors</a></li>
	<li class="active"><a href="index.php?module=BlogTagsAdmin">Tags</a></li>
{/capture}

{if $tag->id}
{$meta_title = $tag->name scope=parent}
{else}
{$meta_title = 'Новая категория' scope=parent}
{/if}

{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

{* On document load *}

<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>
<script src="design/js/autocomplete/jquery.autocomplete-min.js"></script>
<script type="text/javascript" src="{$config->root_url}/js/fancybox/jquery.fancybox.min.js"></script>
<link rel="stylesheet" href="{$config->root_url}/js/fancybox/jquery.fancybox.min.css" type="text/css" media="screen" />
{literal}
<style>
.autocomplete-w1 { background:url(img/shadow.png) no-repeat bottom right; position:absolute; top:0px; left:0px; margin:6px 0 0 6px; /* IE6 fix: */ _background:none; _margin:1px 0 0 0; }
.autocomplete { border:1px solid #999; background:#FFF; cursor:default; text-align:left; overflow-x:auto; min-width: 300px; overflow-y: auto; margin:-6px 6px 6px -6px; /* IE6 specific: */ _height:350px;  _margin:0; _overflow-x:hidden; }
.autocomplete .selected { background:#F0F0F0; }
.autocomplete div { padding:2px 5px; white-space:nowrap; }
.autocomplete strong { font-weight:normal; color:#3399FF; }
</style>

<script>
$(function() {
	
	// Зум картинок
	$("a.zoom").fancybox({prevEffect: 'fade', nextEffect: 'fade'});	


	// Удаление файлов
	$(".image_file a.delete").click( function() {
		$("input[name='delete_image']").val('1');
		$(this).closest("ul").fadeOut(200, function() { $(this).remove(); });
		return false;
	});

	// Автозаполнение мета-тегов
	meta_title_touched = true;
	url_touched = true;
	
	if($('input[name="meta_title"]').val() == generate_meta_title() || $('input[name="meta_title"]').val() == '')
		meta_title_touched = false;
	if($('input[name="url"]').val() == generate_url() || $('input[name="url"]').val() == '')
		url_touched = false;
		
	$('input[name="meta_title"]').change(function() { meta_title_touched = true; });
	$('input[name="url"]').change(function() { url_touched = true; });
	$('input[name="name"]').keyup(function() { set_meta(); });
	
	
	// Удалить 
	$(".languages a.del").click(function() {
		$(this).closest("form").find('input[name="action"]').val('delete');
		$(this).closest("form").submit();
	});

	
	// Подтвердить удаление
	$("form").submit(function() {
		if($('input[name="action"]').val()=='delete' && !confirm('Please, confirm deletion')){
			$('input[name="action"]').val('');
			return false;
		}
	});


	$("table.related_posts").sortable({ items: 'tr' , axis: 'y',  cancel: '#header', handle: '.move_zone' });

	// Сортировка связанных товаров
	$(".sortable").sortable({
		items: "div.row",
		tolerance:"pointer",
		scrollSensitivity:40,
		opacity:0.7,
		handle: '.move_zone'
	});

	// Удаление связанного товара
	$(".related_posts a.delete").live('click', function() {
		 $(this).closest("div.row").fadeOut(200, function() { $(this).remove(); });
		 return false;
	});
 

	// Добавление связанного товара 
	var new_related_post = $('#new_related_post').clone(true);
	$('#new_related_post').remove().removeAttr('id');
 
	$("input#related_posts").autocomplete({
		serviceUrl:'ajax/search_posts.php',
		minChars:0,
		noCache: false, 
		onSelect:
			function(suggestion){
				$("input#related_posts").val('').focus().blur(); 
				new_item = new_related_post.clone().appendTo('.related_posts');
				new_item.removeAttr('id');
				new_item.find('a.related_post_name').html(suggestion.data.name);
				new_item.find('a.related_post_name').attr('href', 'index.php?module=ProductAdmin&id='+suggestion.data.id);
				new_item.find('input[name*="related_posts"]').val(suggestion.data.id);
				if(suggestion.data.image)
					new_item.find('img.product_icon').attr("src", suggestion.data.image);
				else
					new_item.find('img.product_icon').remove();
				new_item.show();
			},
		formatResult:
			function(suggestions, currentValue){
				var reEscape = new RegExp('(\\' + ['/', '.', '*', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].join('|\\') + ')', 'g');
				var pattern = '(' + currentValue.replace(reEscape, '\\$1') + ')';
  				return (suggestions.data.image?"<img align=absmiddle src='"+suggestions.data.image+"'> ":'') + suggestions.value.replace(new RegExp(pattern, 'gi'), '<strong>$1<\/strong>');
			}

	});
  
});

function set_meta()
{
	if(!meta_title_touched)
		$('input[name="meta_title"]').val(generate_meta_title());
	if(!url_touched)
		$('input[name="url"]').val(generate_url());
}

function generate_meta_title()
{
	name = $('input[name="name"]').val();
	return name;
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
	<span class="text">{if $message_success=='added'}Tag added{elseif $message_success=='updated'}Tag updated{else}{$message_success}{/if}</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Back</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">{if $message_error=='url_exists'}Tag with this url already exists{else}{$message_error}{/if}</span>
	<a class="button" href="">Back</a>
</div>
<!-- Системное сообщение (The End)-->
{/if}


<!-- Основная форма -->
<form method=post id=product enctype="multipart/form-data">
<input type=hidden name="session_id" value="{$smarty.session.id}">
	<div id="name">
		<input class="name" name=name type="text" value="{$tag->name|escape}"/> 
		<input name=id type="hidden" value="{$tag->id|escape}"/>
        <input name=content_id type="hidden" value="{$tag->content_id|escape}"/>
        <input name=action type="hidden" value="0"/> 
        {if $tag->id}
        	<input name=language_id type="hidden" value="{$tag->language_id|escape}"/>
        {/if}
		<div class="checkbox">
			<input name=visible value='1' type="checkbox" id="active_checkbox" {if $tag->visible}checked{/if}/> <label for="active_checkbox">Active</label>
		</div>
	</div> 


		
	<!-- Левая колонка свойств товара -->
	<div id="column_left">
			
		<!-- Параметры страницы -->
		<div class="block layer">
			<h2>Page properties</h2>
			<ul>
				<li><label class=property>Url</label><input name="url" class="backend_inp" type="text" value="{$tag->url|escape}" /></li>
				<li><label class=property>Title</label><input name="meta_title" class="backend_inp" type="text" value="{$tag->meta_title|escape}" /></li>
				<li><label class=property>Description</label><textarea name="meta_description" class="backend_inp"/>{$tag->meta_description|escape}</textarea></li>
			</ul>
		</div>
		<!-- Параметры страницы (The End)-->
			
	</div>
	<!-- Левая колонка свойств товара (The End)--> 
	
	<!-- Правая колонка свойств товара -->	
	<div id="column_right">
		
		<!-- Изображение категории -->	
		<div class="block layer images image_file">
			<h2>Image</h2>
			<input class='upload_image' name=image type=file>			
			<input type=hidden name="delete_image" value="">
			{if $tag->image}
			<ul>
				<li>
					<a href='#' class="delete"><img src='design/images/cross-circle-frame.png'></a>
					<a class="zoom" rel="group" href="../{$config->blog_tags_images_dir}{$tag->image}"><img src="{$tag->image|resize:blog_tag:100:100}" alt="" /></a>
				</li>
			</ul>
			{/if}
		</div>

        
	</div>
	<!-- Правая колонка свойств товара (The End)--> 

	<!-- Описагние категории -->
	<div class="block layer">
		<h2>Text</h2>
		<textarea name="description" class="editor_large">{$tag->description|escape}</textarea>
	</div>
	<!-- Описание категории (The End)-->
	<input class="button_green button_save" type="submit" name="" value="Apply" />
	
</form>
<!-- Основная форма (The End) -->

