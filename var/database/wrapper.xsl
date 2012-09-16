<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dt="http://xsltsl.org/date-time" xmlns:str="http://xsltsl.org/string">
	<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes"/>
	<xsl:include href="date-time.xsl"/>
	<xsl:include href="string.xsl"/>
	<xsl:include href="config.xsl"/>
	<xsl:template match="/">
        <html>
			<HEAD>
				<TITLE>iBRAIN project overview</TITLE>
				<link rel="icon" type="image/png" href="{$htmlpath}/img/favicon.png" />
				<SCRIPT LANGUAGE="JavaScript" SRC="{$htmlpath}/js/ibrain3.js"/>
				<!-- xmas snow flakes... Hohoho -->
				<!-- SCRIPT LANGUAGE="JavaScript" SRC="{$htmlpath}/js/snowstorm.js"/ -->
				<LINK REL="stylesheet" HREF="{$htmlpath}/css/ibrain3.css"/>
				<!-- meta http-equiv="refresh" content="1800"/ --><!-- refresh every 15 minutes -->
			</HEAD>
			<body onload="highlightRows();">
				<a name="top"/>
				<table border="0" cellpadding="0" cellspacing="0" style="height: 100%; width: 100%;" width="100%" id="mainContainerTable">
					<tbody>
						<tr id="HeaderTR" class="headerTrOnline" valign="bottom">
							<td id="HeaderTD" height="79" valign="bottom" nowrap="true" width="30%" class="headerOnline">
							<!-- the following div passes the current page date to javascript, for checking if page is still "fresh" -->
							updated on 
							<xsl:call-template name="dt:format-date-time">
								<xsl:with-param name="year">20<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,1,2)"/>
								</xsl:with-param>
								<xsl:with-param name="month">
									<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,3,2)"/>
								</xsl:with-param>
								<xsl:with-param name="day">
									<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,5,2)"/>
								</xsl:with-param>
								<xsl:with-param name="hour">
									<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,8,2)"/>
								</xsl:with-param>
								<xsl:with-param name="minute">
									<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,11,2)"/>
								</xsl:with-param>
								<xsl:with-param name="second">
									<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,14,2)"/>
								</xsl:with-param>
								<xsl:with-param name="time-zon"/>
								<xsl:with-param name="format" select="'%A %d %B %Y at %H:%M'"/>
							</xsl:call-template>
							<div id="reportStalePage" style="font-size: 12px; font-weight: bold; display: none;">
								<xsl:call-template name="dt:format-date-time">
									<xsl:with-param name="year">20<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,1,2)"/>
									</xsl:with-param>
									<xsl:with-param name="month">
										<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,3,2)"/>
									</xsl:with-param>
									<xsl:with-param name="day">
										<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,5,2)"/>
									</xsl:with-param>
									<xsl:with-param name="hour">
										<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,8,2)"/>
									</xsl:with-param>
									<xsl:with-param name="minute">
										<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,11,2)"/>
									</xsl:with-param>
									<xsl:with-param name="second">
										<xsl:value-of select="substring(/ibrain_log/ibrain_meta/start,14,2)"/>
									</xsl:with-param>
									<xsl:with-param name="time-zon"/>
									<xsl:with-param name="format" select="'%a, %d %b %Y %H:%M:%S GMT+0100'"/>
								</xsl:call-template>
							</div>							
<!-- img alt="" src="{$htmlpath}/img/bullet.png" width="14" height="13"/><span style="color: #eeeeee;">author <xsl:value-of select="ibrain_log/ibrain_meta/author"/></span><img alt="" src="{$htmlpath}/img/bullet.png" width="14" height="13"/><span style="color: #dddddd;">version <xsl:value-of select="ibrain_log/ibrain_meta/version"/></span -->
							</td>
							<td height="79" valign="bottom" align="right" style="color: white; font-size: 9pt; padding-right: 24px; font-smooth: always; width: 70%;" nowrap="nowrap" width="70%">
								
								<a href="/share-2/Data/Code/iBRAIN/database/wrapper_xml/wrapper.html" style="float: right bottom;"><img alt="" src="{$htmlpath}/img/tab_home_2.png" width="70" height="24"/></a><!-- previous width 52 -->
								<a target="projectFrame" href="https://wiki-bsse.ethz.ch/display/IMSBP/iBRAIN+Documentation" style="float: right bottom;"><img alt="" src="{$htmlpath}/img/tab_wiki_2.png" width="70" height="24"/></a><!-- previous width 52 -->
								<!-- a href="/share-2/Data/Code/iBRAIN/database/wrapper_xml/wrapper.html" style="color: white; font-size: 9pt; font-weight: bold;">HOME</a><img alt="" src="{$htmlpath}/img/bullet.png" width="14" height="13"/>
								<a target="projectFrame" href="https://wiki.systemsx.ch/x/TAPGAQ" style="color: white; font-size: 9pt; font-weight: bold;">WIKI</a><img alt="" src="{$htmlpath}/img/bullet.png" width="14" height="13"/ -->
							</td>
						</tr>
						<tr style="height: 100%;">
							<td align="center" valign="top" width="30%" height="100%">
								<!-- h2>
									<img src="{$htmlpath}/img/text_bold.png" align="right" width="24" height="24" style="margin-left: 5px; margin-right: 5px; vertical-align: middle;"/>iBRAIN Log file: <xsl:value-of select="ibrain_log/ibrain_meta/start"/>
								</h2>
								<span style="font-size: 10px; font-family: arial;">
									author <xsl:value-of select="ibrain_log/ibrain_meta/author"/> | 
									version <xsl:value-of select="ibrain_log/ibrain_meta/version"/> | 
									script <xsl:value-of select="ibrain_log/ibrain_meta/scriptname"/> |
									hostname <xsl:value-of select="ibrain_log/ibrain_meta/hostname"/>
								</span><br/ -->
								<xsl:apply-templates select="ibrain_log/projects"/>
							</td>
							<td align="left" valign="top" style="width: 100%; height: 100%;">
									 <iframe id="projectFrame" name="projectFrame" src="home.html" frameborder="0" style="width: 100%; height: 100%;"></iframe>
							</td>
						</tr>
						<tr>
							<td style="background-image: url('{$htmlpath}/img/border_bottom.png'); background-repeat: repeat-x; height: 10px;"><img alt="error" src="{$htmlpath}/img/empty.gif" width="1" height="10"/></td>
							<td><img alt="error" src="{$htmlpath}/img/empty.gif" width="1" height="1"/></td>
						</tr>
					</tbody>
				</table>				
			</body>
		</html>
	</xsl:template>
	<xsl:template match="projects">
		<!-- only process those projects with valid paths -->
		<table border="0" class="navTable" cellpadding="0" cellspacing="0" width="100%" id="navTable">
			<tbody>
				<tr class="noRow" id="columnTitle" style="height: 20px;" valign="bottom"> <!--  style="background: url(<xsl:value-of select="$htmlpath" />/img/header_bg_lightblue3.gif) top left repeat-x;  -->
				
					<td colspan="6" align="center" style="font-size: 14px;padding-top: 2px; padding-bottom: 2px;" valign="bottom" id="columnTitleCell">
					<span style="float: left; margin-left: 2px;"><a href="javascript:showAdvancedColumns();"  id="showAdvancedColumns" style="font-size: 12px; color: #988888;" title="toggle display advanced fields">&gt;&gt;</a></span>
						<!-- img alt="" src="{$htmlpath}/img/empty.gif" width="1" height="16" align="left middle"/--> 
						Projects <!-- (<xsl:value-of select="/ibrain_log/ibrain_meta/start"/>) -->
					</td>
					<!-- td align="right" valign="middle"><a href="#"  id="showAdvancedColumns" onclick="javascript: showAdvancedColumns();" style="color: #988888;" title="toggle display advanced fields">&gt;&gt;</a></td -->
				</tr>
				<tr class="noRow" id="columnHeaders">
					<td align="right" title="Status overview">
						<b>Status</b>
					</td>				
					<td align="left" id="_advanced_Header_1" style="display: none;" title="iBRAIN Update information">
						<b>Update</b>
					</td>
					<td align="right" id="_advanced_Header_2" style="display: none;" title="Number of actively running jobs">
						<b>Running</b>
					</td>					
					<td align="right" id="_advanced_Header_3" style="display: none;" title="Date last modified of the project directory" nowrap="nowrap">
						<b>Date modified</b>
					</td>					
					<td align="right" title="NAS share number">
						<img alt="Share" src="{$htmlpath}/img/diskdrive.png" width="16" height="16" align="left"/>
					</td>
					<td align="left" title="NAS path">
						<img alt="Path" src="{$htmlpath}/img/data.png" width="16" height="16"/>
					</td>
					<td align="right" title="Number of plates">
						<img alt="Plates" src="{$htmlpath}/img/plate.gif" width="16" height="16"/>
					</td>
					<!--td align="right" title="Number of jobs in queue (within last hour)" -->
					<td align="right" title="Number of currently running jobs">
						<img alt="Jobs" src="{$htmlpath}/img/gears_run.png" width="16" height="16"/>
					</td>
					<td align="right" title="Number of warnings">
						<img alt="Problems" src="{$htmlpath}/img/gear_warning.png" width="16" height="16"/>
					</td>
				</tr>
				<xsl:for-each select="project[not(warning[@type = 'InvalidPath'])]">
					<!-- sort plates by level of interest jobs/warnings/plates -->
					<xsl:sort data-type="number" order="descending" select="normalize-space(job_count_total)"/>
					<xsl:sort data-type="number" order="descending" select="normalize-space(warning_count)"/>
					<xsl:sort data-type="number" order="descending" select="normalize-space(plate_count)"/>
					<!-- tr onclick="changeiFrameUrl('{concat('../', translate(substring-before(substring-after(normalize-space(current_project_xml_file),'\iBRAIN\database\'),'.xml'),'\','/'), '.html')}')" style="cursor: pointer;" -->
					<!-- tr onclick="changeiFrameUrl('{normalize-space(current_project_xml_file)}')" style="cursor: pointer;" -->
					<tr style="cursor: pointer;">
						<xsl:choose>
							<xsl:when test="latest_project_html_file and not( normalize-space(latest_project_html_file) = '')">
								<xsl:attribute name="onclick">changeiFrameUrl('<xsl:value-of select="normalize-space(latest_project_html_file)"/>','<xsl:value-of select="normalize-space(project_id)"/>')</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="onclick">changeiFrameUrl('no_project_yet.html','<xsl:value-of select="normalize-space(project_id)"/>')</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="position() mod 2 = 1">
								<xsl:attribute name="class">oddRow</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class">evenRow</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<td align="right" title="Status overview">
						<xsl:choose>
							<xsl:when test="latest_project_html_file and not( normalize-space(latest_project_html_file) = '')">
								<a href="{normalize-space(latest_project_html_file)}" target="projectFrame">
									<xsl:attribute name="id"><xsl:value-of select="normalize-space(project_id)"/></xsl:attribute>
									<img alt="error" src="{$htmlpath}/img/empty.gif" width="1" height="1"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<a href="no_project_yet.html" target="projectFrame">
									<xsl:attribute name="id"><xsl:value-of select="normalize-space(project_id)"/></xsl:attribute>
									<img alt="error" src="{$htmlpath}/img/empty.gif" width="1" height="1"/>
								</a>
							</xsl:otherwise>
						</xsl:choose>						
							<xsl:choose>
								<xsl:when test="warning_count &gt; 0">
									<img alt="error" src="{$htmlpath}/img/warning.png" width="16" height="16" class="statusIcon"/>
								</xsl:when>
								<xsl:when test="job_count_present &gt; 0">
									<img alt="running" src="{$htmlpath}/img/media_play_green.png" width="16" height="16" class="statusIcon"/>
								</xsl:when>
								<xsl:otherwise>
									<img alt="ok" src="{$htmlpath}/img/check.png" width="16" height="16" class="statusIcon"/>
								</xsl:otherwise>
							</xsl:choose>
							<!-- we should add the update status and reason to the HTML overview! -->
						</td>
						<td style="font-size: 11px; display: none;" title="iBRAIN Update information" align="left">
							<xsl:attribute name="id">_advanced_Field_1_<xsl:value-of select="generate-id(.)"/></xsl:attribute>
							<xsl:choose>
								<xsl:when test="normalize-space(update_info/@reason) = 'nothing_new'">
									<xsl:value-of select="update_info/@reason"/>
								</xsl:when>
								<xsl:otherwise>
									<b><xsl:value-of select="update_info/@reason"/></b>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td style="display: none;" align="right" title="Number of actively running jobs">
							<xsl:attribute name="id">_advanced_Field_2_<xsl:value-of select="generate-id(.)"/></xsl:attribute>
							<xsl:if test="job_count_present = 0">
								<xsl:attribute name="style">display: none; color: #999999;</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="normalize-space(job_count_running)"/><!-- total jobs minus running equals pending jobs, let's also display that information... --><xsl:if test="number(job_count_present) - number(job_count_running) &gt; 0">/<xsl:value-of select="number(job_count_present) - number(job_count_running)"/></xsl:if>  							
						</td>
						<td style="display: none;" align="right" title="Number of actively running jobs" nowrap="nowrap">
							<xsl:attribute name="id">_advanced_Field_3_<xsl:value-of select="generate-id(.)"/></xsl:attribute>
							<xsl:value-of select="substring(normalize-space(date_last_modified),1,19)"/>
						</td>						
						<td align="right" title="NAS share number">
							<xsl:choose>
								<xsl:when test="contains(path,'/Data/Users/')">
									<xsl:value-of select="substring(normalize-space(path),8,1)"/>									
								</xsl:when>
							</xsl:choose>
						</td>
						<td style="font-size: 11px;" align="left">
							<!-- xsl:value-of  select="concat('../', translate(substring-before(substring-after(normalize-space(current_project_xml_file),'\iBRAIN\database\'),'.xml'),'\','/'), '.html')"/ -->
							<!-- a href="{normalize-space(current_project_xml_file)}" target="projectFrame"><xsl:value-of select="substring-after(normalize-space(path),'\Data\Users\')"/></a -->
							<!-- a 	href="{concat('../', translate(substring-before(substring-after(normalize-space(current_project_xml_file),'\iBRAIN\database\'),'.xml'),'\','/'), '.html')}" target="projectFrame" -->
							<xsl:choose>
								<xsl:when test="contains(path,'/Data/Users/')">
									<xsl:value-of select="substring-after(normalize-space(path),'/Data/Users/')"/>									
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(path)"/>
								</xsl:otherwise>
							</xsl:choose>
							<!-- /a -->
						</td>
						<td align="right" title="Number of plates">
							<xsl:value-of select="normalize-space(plate_count)"/>
						</td>
						<td align="right" title="Number of jobs currently running">
						<!-- td align="right" title="Number of jobs in queue (within last hour)">
							<xsl:if test="job_count_total = 0">
								<xsl:attribute name="style">color: #999999;</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="normalize-space(job_count_total)"/ -->
							<xsl:if test="job_count_present = 0">
								<xsl:attribute name="style">color: #999999;</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="normalize-space(job_count_running)"/><xsl:if test="number(job_count_present) - number(job_count_running) &gt; 0">/<xsl:value-of select="number(job_count_present) - number(job_count_running)"/></xsl:if>   							
						</td>
						<td align="right" title="Number of warnings">
							<xsl:if test="warning_count = 0">
								<xsl:attribute name="style">color: #999999;</xsl:attribute>
							</xsl:if>						
							<xsl:value-of select="normalize-space(warning_count)"/>
						</td>
					</tr>
				</xsl:for-each>
				<!-- list processes with invalid paths -->
				<xsl:for-each select="project[warning[@type = 'InvalidPath'] and substring(path, 1, 3) != 'DIS']">
					<tr onclick="changeiFrameUrl('incorrect_path.html')" class="errorRow">
						<td align="right">
							<img alt="Error" src="{$htmlpath}/img/error.png" width="16" height="16" class="statusIcon"/>
						</td>
						<td/>
						<td colspan="8" style="font-size: 11px;">
							<xsl:value-of select="normalize-space(path)"/>
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
		<!-- hide all projects with disabled paths -->
		<!-- xsl:for-each select="project[warning[@type = 'InvalidPath'] and substring(path, 1, 3) = 'DIS']">
			<div class="invalid-path">
				<xsl:value-of select="path"/>
				<br/>
			</div>
		</xsl:for-each -->
	</xsl:template>
	<!-- unmatched elements -->
	<xsl:template match="*">
		<!-- do nothing with unmatched elements -->
	</xsl:template>
</xsl:stylesheet>
