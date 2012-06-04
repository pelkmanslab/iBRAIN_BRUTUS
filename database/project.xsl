<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:dt="http://xsltsl.org/date-time" xmlns:str="http://xsltsl.org/string">
	<xsl:output method="html" version="4.0" encoding="iso-8859-1" indent="yes"/>
	<xsl:include href="date-time.xsl"/>
	<xsl:include href="string.xsl"/>
	<xsl:param name="thisFileName" select="normalize-space(/project/this_file_name)"/>
	<xsl:template match="/">
		<html>
			<HEAD>
				<TITLE>iBRAIN project overview</TITLE>
				<SCRIPT LANGUAGE="JavaScript" SRC="/js/ibrain2.js"/>

				<!-- jsProgressBarHandler prerequisites : prototype.js -->
				<SCRIPT type="text/javascript" src="/js/prototype.js"/>
				<!-- jsProgressBarHandler core -->
				<SCRIPT type="text/javascript" src="/js/jsProgressBarHandler.js"/>
				
				<LINK REL="stylesheet" HREF="/css/ibrain3.css"/>
				<!-- refresh every 3 minutes -->
				<meta http-equiv="refresh" content="180"/>
				<META HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
			</HEAD>
			<body onload="highlightRows();">
				<div id="container">
					<xsl:apply-templates select="project"/>
					<!-- xsl:value-of select="document('./project_xml/__BIOL__imsb__fs2__bio3__bio3__Data__Users__Berend__081006-berend/project_xml_file_list.xml')/project_xml_file_list"/>
					<xsl:apply-templates select="document('./project_xml/__BIOL__imsb__fs2__bio3__bio3__Data__Users__Berend__081006-berend/project_xml_file_list.xml')"/ -->
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="project">
		<table width="100%" cellpadding="2" cellspacing="0">
			<tbody>
				<tr id="columnTitle" class="noRow">
					<td colspan="8" align="center">
						<!-- style="background-color: #989697; border-bottom: 1px #D7D8DA solid;"  -->
						Plates </td>
				</tr>
				<tr class="noRow" id="projectHeader">
					<td align="left" valign="top">
						<h3>
							<img alt="Share" src="/img/diskdrive.png" width="16" height="16"
								border="0" align="bottom" style="vertical-align: bottom;"
							/>
							<xsl:choose>
								<xsl:when test="contains(path,'/Data/Users/')">
									share-<xsl:value-of select="substring(normalize-space(path),8,1)"
									/>-$/.../<xsl:value-of
										select="substring-after(normalize-space(path),'/Data/Users/')"/>									
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="normalize-space(path)"/>
								</xsl:otherwise>
							</xsl:choose>
						</h3>
						<!-- filename of the cellprofile pipeline -->
						<img alt="CellProfiler pipeline" src="/img/matlab_file.png" width="16"
							height="16" border="0" align="bottom" style="vertical-align: bottom;"/>
						<!-- PreCluster_<xsl:value-of select="substring-after(normalize-space(pipeline),'PreCluster_')"/> -->
						<xsl:choose>
							<xsl:when test="normalize-space(pipeline) = ''">(no project pipeline
								specified)</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="substring-after-last">
									<xsl:with-param name="input" select="normalize-space(pipeline)"/>
									<xsl:with-param name="substr" select="'/'"/>
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td align="right" valign="top">
						<!-- get the date from the file name, using the date-time xsl standard library function -->
						<!-- xsl:variable name="thisFileBaseName" select="substring-after(substring-after($thisFileName,'xml/'),'/')"/ -->
						<xsl:variable name="thisFileBaseName" select="normalize-space(now)"/>
						<h3>
							<xsl:call-template name="dt:format-date-time">
								<xsl:with-param name="year">20<xsl:value-of
										select="substring($thisFileBaseName,1,2)"/>
								</xsl:with-param>
								<xsl:with-param name="month">
									<xsl:value-of select="substring($thisFileBaseName,3,2)"/>
								</xsl:with-param>
								<xsl:with-param name="day">
									<xsl:value-of select="substring($thisFileBaseName,5,2)"/>
								</xsl:with-param>
								<xsl:with-param name="hour">
									<xsl:value-of select="substring($thisFileBaseName,8,2)"/>
								</xsl:with-param>
								<xsl:with-param name="minute">
									<xsl:value-of select="substring($thisFileBaseName,10,2)"/>
								</xsl:with-param>
								<xsl:with-param name="second">
									<xsl:value-of select="substring($thisFileBaseName,12,2)"/>
								</xsl:with-param>
								<xsl:with-param name="time-zon"/>
								<xsl:with-param name="format" select="'%A, %H:%M, %d %B %Y'"/>
							</xsl:call-template>
						</h3>
						<!-- basic data link -->
						<xsl:choose>
							<xsl:when test="files/file[@type = 'basic_data_csv']">
								<!-- pull down with all basic/plate data files ... -->
								<form name="form"
									style="clear: none; align: left; float: right; margin-left: 10px; margin-top:2px; border: 0px;">
									<select name="site" size="1"
										onChange="javascript:formHandler(this)"
										style="font-size: 9px; margin: 0px; padding: 0px; border: 0px;">
										<!-- //-->
										<option value=""
											style="font-size: 9px; margin: 0px; padding: 0px; border: 0px; color: #666666;"
											>plate data files (<xsl:value-of
												select="count(files/file[@type = 'basic_data_csv'])"
											/>)</option>
										<xsl:for-each select="files/file[@type = 'basic_data_csv']">
											<option value="{normalize-space(node())}"
												style="font-size: 9px; margin: 0px; padding: 0px; border: 0px;">
												<xsl:call-template name="substring-after-last">
												<xsl:with-param name="input"
												select="normalize-space(normalize-space(node()))"/>
												<xsl:with-param name="substr" select="'/'"/>
												</xsl:call-template>
											</option>
										</xsl:for-each>
									</select>
								</form>
								<!-- a href="{normalize-space(files/file[@type = 'basic_data_csv'])}" target="_blank">
									<img alt="Basic data csv" src="/img/document.png" width="16" height="16" border="0" align="bottom" style="vertical-align: bottom;"/> Plate overview
								</a -->
							</xsl:when>
						</xsl:choose>
						<!-- advanced data link -->
						<xsl:choose>
							<xsl:when test="files/file[@type = 'advanced_data_csv']">
								<!-- pull down with all advanced/gene data files ... -->
								<form name="form"
									style="clear: none; align: left; float: right; margin-left: 10px; margin-top:2px; border: 0px;">
									<select name="site" size="1"
										onChange="javascript:formHandler(this)"
										style="font-size: 9px; margin: 0px; padding: 0px; border: 0px;">
										<option value=""
											style="font-size: 9px; margin: 0px; padding: 0px; border: 0px; color: #666666;"
											>gene data files (<xsl:value-of
												select="count(files/file[@type = 'advanced_data_csv'])"
											/>)</option>
										<xsl:for-each
											select="files/file[@type = 'advanced_data_csv']">
											<option value="{normalize-space(node())}"
												style="font-size: 9px; margin: 0px; padding: 0px; border: 0px;">
												<xsl:call-template name="substring-after-last">
												<xsl:with-param name="input"
												select="normalize-space(normalize-space(node()))"/>
												<xsl:with-param name="substr" select="'/'"/>
												</xsl:call-template>
											</option>
										</xsl:for-each>
									</select>
								</form>
								<!--a href="{normalize-space(files/file[@type = 'advanced_data_csv'])}" target="_blank">
									<img alt="Advanced data csv" src="/img/document.png" width="16" height="16" border="0" align="bottom" style="vertical-align: bottom;"/> Gene overview
								</a -->
							</xsl:when>
							<!-- xsl:otherwise>
								<img alt="" src="/img/empty.gif" width="16" height="16"/>
							</xsl:otherwise -->
						</xsl:choose>
						<!-- navigation for other/older/newer versions -->
						<!-- xsl:variable name="projXmlFileUri" select="concat('./project_xml/',substring-after(normalize-space(/project/project_xml_dir),'project_xml/'), '/project_xml_file_list.xml')"/>
						<xsl:apply-templates select="document($projXmlFileUri)/project_xml_file_list"/ -->
					</td>
				</tr>
				<!-- tr class="noRow" id="projectHeader">
					<td colspan="2">
						<img alt="CellProfiler pipeline" src="/img/matlab_file.png" width="16" height="16" border="0" align="bottom" style="vertical-align: bottom;"/> PreCluster_<xsl:value-of select="substring-after(normalize-space(pipeline),'PreCluster_')"/>
					</td>
				</tr>
				<tr class="noRow" id="projectHeader">
					<td>
						<xsl:choose>
							<xsl:when test="files/file[@type = 'basic_data_csv']">
								<a href="{normalize-space(files/file[@type = 'basic_data_csv'])}" target="_blank">
									<img alt="Basic data csv" src="/img/document.png" width="16" height="16" border="0" align="bottom" style="vertical-align: bottom;"/> Plate overview
								</a>
							</xsl:when>
							<xsl:otherwise>
								<img alt="" src="/img/empty.gif" width="16" height="16"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="files/file[@type = 'advanced_data_csv']">
								<a href="{normalize-space(files/file[@type = 'advanced_data_csv'])}"  target="_blank">
									<img alt="Advanced data csv" src="/img/document.png" width="16" height="16" border="0" align="bottom" style="vertical-align: bottom;"/> Gene overview
								</a>
							</xsl:when>
							<xsl:otherwise>
								<img alt="" src="/img/empty.gif" width="16" height="16"/>
							</xsl:otherwise>
						</xsl:choose>
					</td>
					<td align="right" valign="top">
						<xsl:variable name="projXmlFileUri" select="concat('./project_xml/',substring-after(normalize-space(/project/project_xml_dir),'project_xml/'), '/project_xml_file_list.xml')"/>
						<xsl:apply-templates select="document($projXmlFileUri)/project_xml_file_list"/>
					</td>
				</tr -->
			</tbody>
		</table>
		<xsl:apply-templates select="plates"/>
		<!-- table width="100%" cellpadding="0" cellspacing="0">
			<tbody>
				<tr class="noRow" id="projectHeader">
					<td height="1px"/>
				</tr>
			</tbody>
		</table -->
	</xsl:template>
	<xsl:template match="plates">
		<table border="0" class="navTable" cellpadding="0" cellspacing="0" width="100%"
			id="plateList">
			<tbody>
				<tr class="noRow" id="columnHeaders">
					<td align="right" width="40">
						<b>Status</b>
					</td>
					<td align="left" valign="top">
						<img alt="Plates" src="/img/plate.gif" width="16" height="16"
							style="margin-right: 5px;"/>
						<b>Plates</b>
						<img alt="" src="/img/empty.gif" width="16" height="2"/>
						<a onclick="collapseAllPlates();" style="color: #888888; cursor: pointer;"
							href="#">
							<img src="/img/minus.gif" width="9" height="9"
								style="vertical-align: baseline; margin-right: 2px;"/>collapse
							all</a>
						<img alt="" src="/img/empty.gif" width="16" height="2"/>
						<a onclick="expandAllPlates();" style="color: #888888; cursor: pointer;"
							href="#">
							<img src="/img/plus.gif" width="9" height="9"
								style="vertical-align: baseline; margin-right: 2px;"/>expand all</a>
					</td>
					<td align="right" width="18">
						<img alt="Jobs" src="/img/gears_run.png" width="16" height="16"/>
					</td>
					<td align="right" width="18">
						<img alt="Problems" src="/img/gear_warning.png" width="16" height="16"/>
					</td>
					<td align="right" width="18">
						<img alt="Plate overview PDF" src="/img/pdf.png" width="16" height="16"/>
					</td>
					<td align="right" width="18">
						<img alt="Plate overview JPG" src="/img/photo_scenery.png" width="16"
							height="16"/>
					</td>
					<td align="right" width="18">
						<img alt="Plate overview CSV" src="/img/document_chart.png" width="16"
							height="16"/>
					</td>
					<td align="right" width="18">
						<img alt="TIFF Folder" src="/img/folder_into.png" width="16" height="16"/>
					</td>
				</tr>
				<xsl:for-each select="plate">
					<!-- sort plates by level of interest jobs/warnings/plates -->
					<xsl:sort data-type="number" order="descending" select="normalize-space(job_count_total)"/>
					<xsl:sort data-type="number" order="descending" select="count(.//warning)"/>
					<xsl:variable name="idName">plate_<xsl:value-of select="generate-id(.)"/>
					</xsl:variable>
					<tr>
						<xsl:choose>
							<xsl:when test="position() mod 2 = 1">
								<xsl:attribute name="class">oddRow</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="class">evenRow</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<!-- onclick="this.parentNode.className = (this.parentNode.className==nodeOpenClass) ? nodeClosedClass : nodeOpenClass;" style="cursor: pointer;" title="{normalize-space(current_project_xml_file)}" -->
						<!-- td><img alt="error" src="/img/empty.gif" width="30" height="16" align="left"/></td -->
						<td align="right" onclick="switchDisplay('{$idName}','tr')"
							style="cursor: pointer;">
							<!-- xsl:value-of select="generate-id(.)"/ -->
							<xsl:choose>
								<xsl:when
									test="count(.//status[normalize-space(node()) = 'paused']) &gt; 0 or count(.//status[substring(normalize-space(node()),1,6) = 'paused']) &gt; 0">
									<img alt="paused" src="/img/media_pause.png" width="16"
										height="16" class="statusIcon"/>
								</xsl:when>
								<xsl:when test="count(.//warning) &gt; 0">
									<img alt="error" src="/img/warning.png" width="16" height="16"
										class="statusIcon"/>
								</xsl:when>
								<xsl:when test="normalize-space(job_count_total) &gt; 0">
									<img alt="running" src="/img/media_play_green.png" width="16"
										height="16" class="statusIcon"/>
								</xsl:when>
								<xsl:otherwise>
									<img alt="ok" src="/img/check.png" width="16" height="16"
										class="statusIcon"/>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td onclick="switchDisplay('{$idName}','tr')" style="nowrap; cursor: pointer;" valign="middle">
							<xsl:choose>
								<xsl:when test="substring(substring-after(normalize-space(plate_dir),normalize-space(/project/path)),2) = ''">
									<xsl:value-of select="normalize-space(plate_name)"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring(substring-after(normalize-space(plate_dir),normalize-space(/project/path)),2)"/>								
								</xsl:otherwise>
							</xsl:choose>
							<xsl:choose>
								<xsl:when test="./status/output/progressbar">
									<span class="progressBar" id="progressbar_{generate-id(./status/output/progressbar)}" style="margin-left: 15px; font-size: 10px; margin-bottom: 2px;"><xsl:value-of select="normalize-space(./status/output/progressbar)"/>%</span><span style="font-size: 10px;"><xsl:text> </xsl:text><xsl:value-of select="normalize-space(normalize-space(./status/output/progressbar/@text))"/></span>
								</xsl:when>
								<xsl:when test="completed_batch_job_count &lt; total_batch_job_count">
									<img alt="empty" src="/img/empty.gif" width="16" height="12"/>
									<span style="font-size: 9px; color: #555555;">(completed
											<xsl:value-of
											select="normalize-space(completed_batch_job_count)"/> of
											<xsl:value-of
											select="normalize-space(total_batch_job_count)"/>
										batchjobs)</span>
								</xsl:when>
							</xsl:choose>
							
							
							
							<!-- PreCluster_<xsl:value-of select="substring-after(normalize-space(pipeline),'PreCluster_')"/> -->
							<xsl:if test="normalize-space(../../pipeline) != normalize-space(pipeline)">
								<xsl:choose>
									<xsl:when test="normalize-space(pipeline) = ''"> </xsl:when>
									<xsl:otherwise>
										<span style="color: #888888; font-size: 9px; float: right; margin-right: 5px;">
											<xsl:call-template name="substring-after-last">
												<xsl:with-param name="input" select="normalize-space(pipeline)"/>
												<xsl:with-param name="substr" select="'/'"/>
											</xsl:call-template>
											<img alt="CellProfiler pipeline" src="/img/matlab_file.png" width="16"
											height="16" border="0" align="bottom" style="vertical-align: bottom;"/>
										</span>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
							
						</td>
						<td align="right">
							<xsl:value-of select="normalize-space(job_count_total)"/>
						</td>
						<td align="right">
							<xsl:value-of select="count(.//warning)"/>
						</td>
						<td align="right">
							<xsl:choose>
								<xsl:when test="files/file[@type = 'plate_overview_pdf']">
									<a
										href="{normalize-space(files/file[@type = 'plate_overview_pdf'])}"
										target="_blank">
										<!-- xsl:value-of select="normalize-space(files/file[@type = 'plate_overview_pdf'])"/ -->
										<img alt="Plate overview pdf" src="/img/pdf.png" width="16"
											height="16"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<img alt="" src="/img/empty.gif" width="16" height="16"/>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td align="right">
							<xsl:choose>
								<xsl:when test="files/file[@type = 'plate_overview_jpg']">
									<a
										href="{normalize-space(files/file[@type = 'plate_overview_jpg'])}"
										target="_blank">
										<img alt="Plate overview jpg" src="/img/photo_scenery.png"
											width="16" height="16"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<img alt="" src="/img/empty.gif" width="16" height="16"/>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td align="right">
							<xsl:choose>
								<xsl:when test="files/file[@type = 'plate_overview_csv']">
									<a
										href="{normalize-space(files/file[@type = 'plate_overview_csv'])}"
										target="_blank">
										<img alt="Document overview csv"
											src="/img/document_chart.png" width="16" height="16"/>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<img alt="" src="/img/empty.gif" width="16" height="16"/>
								</xsl:otherwise>
							</xsl:choose>
						</td>
						<td align="right">
							<a href="{normalize-space(plate_dir)}" target="_blank">
								<img alt="Plate directory" src="/img/folder_into.png" width="16"
									height="16"/>
							</a>
						</td>
					</tr>
					<xsl:apply-templates select="status">
						<xsl:with-param name="idName" select="$idName"/>
					</xsl:apply-templates>
				</xsl:for-each>
				<!-- also run non-plate status fields, i.e. project-specific status fields like fuse-basic-data -->
				<xsl:apply-templates select="../status"/>
				<tr style="border: 0px;">
					<td
						style="background-image: url('/img/border_bottom.png'); background-repeat: repeat-x; height: 10px; border: 0px;"
						colspan="14">
						<img alt="error" src="/img/empty.gif" width="1" height="10"/>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	<xsl:template match="status">
		<xsl:param name="idName"/>
		<tr class="statusItem">
			<xsl:if test="not(../../project)">
				<xsl:attribute name="style">display: none;</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="id">
				<xsl:value-of select="$idName"/>
			</xsl:attribute>
			<td width="40">
				<img alt="empty" src="/img/empty.gif" width="1" height="1"/>
			</td>
			<td>
				<xsl:if test="parent::status">
					<img alt="empty" src="/img/empty.gif" width="22" height="16" align="left"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when
						test="normalize-space(node()) = 'paused' or substring(normalize-space(node()),1,6) = 'paused'">
						<img alt="job paused" src="/img/gear_pause.png" width="16" height="16"
							class="statusIcon"/>
					</xsl:when>
					<xsl:when
						test="normalize-space(node()) = 'failed' or normalize-space(node()) = 'unknown' or (substring(normalize-space(node()),1,6) = 'PROCES'  and count(.//status[normalize-space(node()) = 'failed' or normalize-space(node()) = 'unknown']) &gt; 0)">
						<img alt="job error" src="/img/gear_error.png" width="16" height="16"
							class="statusIcon"/>
					</xsl:when>
					<xsl:when
						test="normalize-space(node()) = 'completed' or normalize-space(node()) = 'skipping' or normalize-space(node()) = 'resetting' or (substring(normalize-space(node()),1,6) = 'PROCES' and count(.//status[normalize-space(node()) = 'completed' or normalize-space(node()) = 'skipping' or normalize-space(node()) = 'resetting']) &gt; 0)">
						<img alt="job error" src="/img/gear_ok.png" width="16" height="16"
							class="statusIcon"/>
					</xsl:when>
					<xsl:otherwise>
						<img alt="job error" src="/img/gear_run.png" width="16" height="16"
							class="statusIcon"/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="@action"/>
				<xsl:if test="not(substring(normalize-space(node()),1,6) = 'PROCES')">
					<xsl:text> = </xsl:text>
					<xsl:value-of select="normalize-space(node())"/>
				</xsl:if>
			</td>
			<td width="18">
				<img alt="" src="/img/empty.gif" width="1" height="1"/>
			</td>
			<td width="18" align="center">
				<img alt="" src="/img/empty.gif" width="1" height="1"/>
				<!-- xsl:choose>
					<xsl:when test=".//result_file and count(.//warning) &gt; 0">
						<a href="{normalize-space(.//warning/result_file[last()])}"  target="_blank">
							<img alt="job error" src="/img/console_error.png" width="16" height="16"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
				        ... empty image
					</xsl:otherwise>
				</xsl:choose -->
			</td>
			<td width="18">
				<img alt="" src="/img/empty.gif" width="1" height="1"/>
				<xsl:choose>
					<xsl:when test="file[@type = 'pdf']">
						<a href="{normalize-space(file[@type = 'pdf'])}" target="_blank">
							<!-- xsl:value-of select="normalize-space(files/file[@type = 'plate_overview_pdf'])"/ -->
							<img alt="PDF file" src="/img/pdf.png" width="16" height="16"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<img alt="" src="/img/empty.gif" width="1" height="1"/>
					</xsl:otherwise>
				</xsl:choose>
			</td>
			<td width="18">
				<!-- place for PDF links -->
				<!-- xsl:choose>
					<xsl:when test="file[@type = 'pdf']">
						<a href="{normalize-space(file[@type = 'pdf'])}"  target="_blank">
							<img alt="Plate overview pdf" src="/img/pdf.png" width="16" height="16"/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<img alt="" src="/img/empty.gif" width="1" height="1"/>
					</xsl:otherwise>
				</xsl:choose -->
			</td>
			<td width="18">
				<xsl:choose>
					<xsl:when test="file[@type = 'csv']">
						<a href="{normalize-space(file[@type = 'csv'])}" target="_blank">
							<!-- xsl:value-of select="normalize-space(files/file[@type = 'plate_overview_pdf'])"/ -->
							<img alt="CSV file" src="/img/document_chart.png" width="16" height="16"
							/>
						</a>
					</xsl:when>
					<xsl:when test="file[@type = 'txt']">
						<a href="{normalize-space(file[@type = 'txt'])}" target="_blank">
							<!-- xsl:value-of select="normalize-space(files/file[@type = 'plate_overview_pdf'])"/ -->
							<img alt="CSV file" src="/img/document.png" width="16" height="16"
							/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<img alt="" src="/img/empty.gif" width="1" height="1"/>
					</xsl:otherwise>
				</xsl:choose>

			</td>
			<td width="18">
				<img alt="" src="/img/empty.gif" width="1" height="1"/>
			</td>
		</tr>
		<xsl:apply-templates select=".//*">
			<xsl:with-param name="idName">
				<xsl:value-of select="$idName"/>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="warning | message | output">
		<xsl:param name="idName"/>
		<xsl:if test="not(normalize-space(node()) = '')">
			<tr class="statusInfo">
				<xsl:if test="not(../../../project)">
					<xsl:attribute name="style">display: none;</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="id">
					<xsl:value-of select="$idName"/>
				</xsl:attribute>
				<td width="40">
					<img alt="empty" src="/img/empty.gif" width="1" height="1"/>
				</td>
				<td>
					<xsl:if test="../../../status">
						<img alt="empty" src="/img/empty.gif" width="22" height="16" align="left"/>
					</xsl:if>
					<!--xsl:if test="parent::plate">
						<img alt="empty" src="/img/empty.gif" width="30" height="16" align="left"/>
					</xsl:if-->
					<img alt="empty" src="/img/empty.gif" width="22" height="16" align="left"/>
					<span>
						<xsl:choose>
							<xsl:when test="local-name() = 'warning'">
								<xsl:attribute name="class">warningInfo</xsl:attribute>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="local-name()"/>: <!-- here we might want to limit really long output to a certain substring.... !  substring(normalize-space(node()), 1, 3000) -->
						<xsl:if test="string-length(normalize-space(node())) &lt; 1000">
							<xsl:value-of select="normalize-space(node())"/>
						</xsl:if>
						<xsl:if test="string-length(normalize-space(node())) &gt; 999">
							<xsl:value-of select="substring(normalize-space(node()), 1, 1000)"/>
							<xsl:text> </xsl:text>
							<strong> ... (Message truncated to 1000 characters, complain if you want
								to see it all).</strong>
						</xsl:if>
					</span>
				</td>
				<td width="18">
					<img alt="" src="/img/empty.gif" width="1" height="1"/>
				</td>
				<td width="18">
					<xsl:choose>
						<xsl:when test="local-name() = 'warning' and ./result_file">
							<a href="{normalize-space(./result_file[last()])}" target="_blank">
								<img alt="job error" src="/img/console_error.png" width="16"
									height="16"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<img alt="" src="/img/empty.gif" width="1" height="1"/>
						</xsl:otherwise>
					</xsl:choose>
				</td>
				<td width="18">
					<img alt="" src="/img/empty.gif" width="1" height="1"/>
				</td>
				<td width="18">
					<img alt="" src="/img/empty.gif" width="1" height="1"/>
				</td>
				<td width="18">
					<img alt="" src="/img/empty.gif" width="1" height="1"/>
				</td>
				<td width="18">
					<img alt="" src="/img/empty.gif" width="1" height="1"/>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>
	<!-- simple navigation! match current document against all documents in xml file list. highlight current file, make all others links -->
	<xsl:template match="project_xml_file_list"> versions: <xsl:for-each select="project_xml_file">
			<xsl:sort data-type="text" order="ascending" select="normalize-space(.)"/>
			<xsl:choose>
				<xsl:when test="$thisFileName = normalize-space(node()) and position() = 1">
					<span style="color: #DDDDDD;">
						<xsl:text>first | </xsl:text>
					</span>
				</xsl:when>
				<xsl:when test="$thisFileName != normalize-space(node()) and position() = 1">
					<a href="{normalize-space(node())}" target="projectFrame">first</a>
					<xsl:text> | </xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$thisFileName = normalize-space(node()) and  position() != 1">
					<a href="{normalize-space(preceding-sibling::project_xml_file[1])}"
						target="projectFrame">previous</a>
					<!-- a href="{normalize-space(.::project_xml_file[position()-1])}" target="projectFrame">previous</a -->
					<xsl:text> | </xsl:text>
				</xsl:when>
				<xsl:when test="$thisFileName = normalize-space(node()) and position() = 1">
					<span style="color: #DDDDDD;">
						<xsl:text>previous | </xsl:text>
					</span>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$thisFileName = normalize-space(node())">
					<b>
						<xsl:value-of select="position()"/>
					</b>
					<xsl:text> | </xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$thisFileName = normalize-space(node()) and position() != last()">
					<a href="{normalize-space(following-sibling::project_xml_file[1])}"
						target="projectFrame">next</a>
					<!-- a href="{normalize-space(.::project_xml_file[position()+1])}" target="projectFrame">next</a -->
					<xsl:text> | </xsl:text>
				</xsl:when>
				<xsl:when test="$thisFileName = normalize-space(node()) and position() = last()">
					<span style="color: #DDDDDD;">
						<xsl:text>next | </xsl:text>
					</span>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$thisFileName = normalize-space(node()) and position() = last()">
					<span style="color: #DDDDDD;">
						<xsl:text>last | </xsl:text>
					</span>
				</xsl:when>
				<xsl:when test="$thisFileName != normalize-space(node()) and position() = last()">
					<a href="{normalize-space(node())}" target="projectFrame">last</a>
					<xsl:text> | </xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="b">
		<b>
			<xsl:value-of select="normalize-space(node())"/>
		</b>
	</xsl:template>

	<xsl:template name="substring-after-last">
		<xsl:param name="input"/>
		<xsl:param name="substr"/>
		<!-- Extract the string which comes after the first occurence -->
		<xsl:variable name="temp" select="substring-after($input,$substr)"/>
		<xsl:choose>
			<!-- If it still contains the search string then recursively process -->
			<xsl:when test="$substr and contains($temp,$substr)">
				<xsl:call-template name="substring-after-last">
					<xsl:with-param name="input" select="$temp"/>
					<xsl:with-param name="substr" select="$substr"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$temp"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*"/>
</xsl:stylesheet>
