{* Вкладки *}
{capture name=tabs}
	{if in_array('issues', $manager->permissions)}
		<li><a href="index.php?module=UsersAdmin">Guests</a></li>
		<li><a href="index.php?module=MoveInAdmin">Move In</a></li>
		<li><a href="index.php?module=FarewellAdmin">Farewell</a></li>
	{/if}
	<li class="active"><a href="index.php?module=IssuesAdmin">Technical Issues</a></li>
	{if in_array("menu_12", $manager->permissions)}
		<li><a href='?module=PagesAdmin&menu_id=12'>For House Leader</a></li>
	{/if}
{/capture}

{if $issue->id}
	{$meta_title = $issue->assignment|escape|truncate:50:'…':true:true scope=parent}
{/if}


{* Подключаем Tiny MCE *}
{include file='tinymce_init.tpl'}

<script src="design/js/jquery/jquery.js"></script>
<script src="design/js/jquery/jquery-ui.min.js"></script>
<script src="design/js/jquery/datepicker/jquery.ui.datepicker-en.js"></script>
<script src="{$config->root_url}/js/jquery.maskedinput.js" type="text/javascript"></script>

{literal}
<script>
$(function() {

$('input[name=date_start], input[name=date_completion]').datepicker({
	//regional:'en'
});

$(".time_mask").mask("99:99");

});

</script>
{/literal}

{if $message_success}
<!-- Системное сообщение -->
<div class="message message_success">
	<span class="text">
		{if $message_success=='updated'}
			Iissue updated
		{elseif $message_success=='added'}
			Issue added
		{else}
			{$message_success|escape}
		{/if}
	</span>
	{if $smarty.get.return}
		<a class="button" href="{$smarty.get.return}">Return</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}

{if $message_error}
<!-- Системное сообщение -->
<div class="message message_error">
	<span class="text">
		{if $message_error=='empty_assignments'}
			Empty assignment
		{else}
			{$message_error|escape}
		{/if}
	</span>
	{if $smarty.get.return}
	<a class="button" href="{$smarty.get.return}">Return</a>
	{/if}
</div>
<!-- Системное сообщение (The End)-->
{/if}



<!-- Основная форма -->
<form method=post id=product>
	<input type=hidden name="session_id" value="{$smarty.session.id}">
	<input name=id type="hidden" value="{$issue->id|escape}"/> 
	<div class="block">
		<div id="name">
			<h2>Assignment</h2>
			<div class="checkbox">
				<input name="visible" value='1' type="checkbox" id="active_checkbox" {if $issue->visible}checked{/if}/> <label for="active_checkbox">Enabled</label>
			</div>
		</div>
		<textarea name="assignment" class='editor_small_ annotation v2'>{$issue->assignment|escape}</textarea>
	</div>

	<div id="column_left">
		<div class="block layer">
			<ul>

				{if $houses}
				<li>
					<label class=property>House</label>
					<select name="house_id">
						<option value='0'>--- Not selected ---</option>
				   		{foreach $houses as $city}
				   			{if $city->subcategories}
					   			<optgroup label="{$city->name|escape}">
					   			{foreach $city->subcategories as $r}
					        		<option value='{$r->id}'{if $issue->house_id==$r->id} selected{/if}>{$r->name|escape}</option>
					        	{/foreach}
					        	</optgroup>
				        	{/if}
				    	{/foreach}
					</select>
				</li>
				{/if}

				{if $statuses}
				<li>
					<label class=property>Status</label>
					<select name="status">
				   		{foreach $statuses as $s_id=>$s_val}
				        	<option value='{$s_id}' {if $issue->status==$s_id}selected{/if}>{$s_val|escape}</option>
				    	{/foreach}
					</select>
				</li>
				{/if}
			</ul>

		</div><!-- block -->

		<div class="block layer">
			<ul>
				<li>
					<label class=property>Start Date</label>
					<input class="inp_date" type=text name=date_start value='{$issue->date_start|date}'>
					<input class="inp_time time_mask backend_inp" name="time_start" type="text" value="{if !$issue->id}11:00{else}{$issue->date_start|time}{/if}">
				</li>
				<li>
					<label class=property>Due on</label>
					<input class="inp_date" type=text name=date_completion value='{if $post->date_completion}{$post->date_completion|date}{/if}'>
					<input class="inp_time time_mask backend_inp" name="time_completion" type="text" value="{if $issue->date_completion}{$issue->date_completion|time}{/if}">
				</li>
			</ul>

			<input class="button_green" type="submit" name="issue_info" value="Save">
		</div><!-- block -->

	</div><!-- column_left -->

	<div id="column_right">
		<div class="block layer">
			<ul>
				<li>
					<label class=property>Email guest</label>
					<input name="email_guest" class="backend_inp" type="text" value="{$issue->email_guest}">
				</li>
				<li>
					<label class=property>Assigned</label>
					<input name="assigned" class="backend_inp" type="text" value="{$issue->assigned}">
				</li>
				<li>
					<label class=property>Details</label>
					<textarea name="details" >{$issue->details|escape}</textarea>
				</li>
			</ul>
		</div><!-- block -->
	</div><!-- column_right -->	
		
</form>
<!-- Основная форма (The End) -->
 




