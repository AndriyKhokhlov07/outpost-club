{* Вкладки *}
{capture name=tabs}
	<li><a href="index.php?module=UsersAdmin">Guests</a></li>
	<li><a href="index.php?module=MoveInAdmin">Move In</a></li>
	<li class="active"><a href="index.php?module=FarewellAdmin">Farewell</a></li>
	{if in_array('issues', $manager->permissions)}<li><a href="index.php?module=IssuesAdmin">Technical Issues</a></li>{/if}

{/capture}

{$meta_title='Farewell'  scope=parent}


{literal}
<!--[if lte IE 8]>
<script charset="utf-8" type="text/javascript" src="//js.hsforms.net/forms/v2-legacy.js"></script>
<![endif]-->
<script charset="utf-8" type="text/javascript" src="//js.hsforms.net/forms/v2.js"></script>
<script>
  hbspt.forms.create({
	portalId: "4068949",
	formId: "6c56fe2b-d1c1-4f93-a264-42ca5bd49060"
});

</script>
{/literal}