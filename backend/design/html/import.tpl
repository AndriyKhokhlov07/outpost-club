{capture name=tabs}
	<li class="active"><a href="index.php?module=ImportAdmin">Import</a></li>
	{if in_array('export', $manager->permissions)}<li><a href="index.php?module=ExportAdmin">Export</a></li>{/if}
	{if in_array('backup', $manager->permissions)}<li><a href="index.php?module=BackupAdmin">Backup</a></li>{/if}
{/capture}
{$meta_title='Products import' scope=parent}

<script src="{$config->root_url}/backend/design/js/piecon/piecon.js"></script>
<script>
{if $filename}
{literal}
	
	var in_process=false;
	var count=1;

	// On document load
	$(function(){
 		Piecon.setOptions({fallback: 'force'});
 		Piecon.setProgress(0);
    	$("#progressbar").progressbar({ value: 1 });
		in_process=true;
		do_import();	    
	});
  
	function do_import(from)
	{
		from = typeof(from) != 'undefined' ? from : 0;
		$.ajax({
 			 url: "ajax/import.php",
 			 	data: {from:from},
 			 	dataType: 'json',
  				success: function(data){
  					for(var key in data.items)
  					{
    					$('ul#import_result').prepend('<li><span class=count>'+count+'</span> <span title='+data.items[key].status+' class="status '+data.items[key].status+'"></span> <a target=_blank href="index.php?module=ProductAdmin&id='+data.items[key].product.id+'">'+data.items[key].product.name+'</a> '+data.items[key].variant.name+'</li>');
    					count++;
    				}

    				Piecon.setProgress(Math.round(100*data.from/data.totalsize));
   					$("#progressbar").progressbar({ value: 100*data.from/data.totalsize });
  				
    				if(data != false && !data.end)
    				{
    					do_import(data.from);
    				}
    				else
    				{
    					Piecon.setProgress(100);
    					$("#progressbar").hide('fast');
    					in_process = false;
    				}
  				},
				error: function(xhr, status, errorThrown) {
					alert(errorThrown+'\n'+xhr.responseText);
        		}  				
		});
	
	} 
{/literal}
{/if}
</script>

<style>
	.ui-progressbar-value { background-color:#b4defc; background-image: url(design/images/progress.gif); background-position:left; border-color: #009ae2;}
	#progressbar{ clear: both; height:29px;}
	#result{ clear: both; width:100%;}
</style>

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">
	{if $message_error == 'no_permission'}Set writable permissions to the folder {$import_files_dir}
	{elseif $message_error == 'convert_error'}Could not convert file to UTF8 charset
	{elseif $message_error == 'locale_error'}There is no {$locale} locale on server. Import may work incorrectly
	{else}{$message_error}{/if}
	</span>
</div>
<!-- Системное сообщение (The End)-->
{/if}

	{if $message_error != 'no_permission'}
	
	{if $filename}
	<div>
		<h1>Import {$filename|escape}</h1>
	</div>
	<div id='progressbar'></div>
	<ul id='import_result'></ul>
	{else}
	
		<h1>Products import</h1>

		<div class="block">	
		<form method=post id=product enctype="multipart/form-data">
			<input type=hidden name="session_id" value="{$smarty.session.id}">
			<input name="file" class="import_file" type="file" value="" />
			<input class="button_green" type="submit" name="" value="Upload" />
			<p>
				(max file size &mdash; {if $config->max_upload_filesize>1024*1024}{$config->max_upload_filesize/1024/1024|round:'2'} MB{else}{$config->max_upload_filesize/1024|round:'2'} KB{/if})
			</p>

			
		</form>
		</div>		
	
		<div class="block block_help">
		<p>
			Create backup before import. 
		</p>
		<p>
			Save products list in CSV format
		</p>
		<p>
			The names of columns could be in the first line of file:
	
			<ul>
				<li><label>Product</label> product name</li>
				<li><label>Category</label> product category</li>
				<li><label>Brand</label> product brand</li>
				<li><label>Variant</label> product variant</li>
				<li><label>Price</label> product price</li>
				<li><label>Compare price</label> compare price</li>
				<li><label>Stock</label> quantity of products in stock</li>
				<li><label>SKU</label> product sku</li>
				<li><label>Visible</label> product visibility (0 or 1)</li>
				<li><label>Featured</label> is product featured (0 or 1)</li>
				<li><label>Annotation</label> product annotation</li>
				<li><label>URL</label> product url</li>
				<li><label>Description</label> product description</li>
				<li><label>Images</label> comma-separated filenames or urls of product images</li>
				<li><label>Meta title</label> title of product page</li>
				<li><label>Meta keywords</label> product keywords</li>
				<li><label>Description страницы</label> description of product page</li>
			</ul>
		</p>
		<p>
			Other column name is treated as name of product feature
		</p>
		<p>
			<a href='files/import/example.csv'>Download example of CSV file</a>
		</p>
		</div>		
	
	{/if}


{/if}