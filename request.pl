#!/usr/bin/perl

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;


#setup colours
print startpage();
print startmenu();
my $blah;
my $bib=$input->param('bib');
my $dat=bibdata($bib);
#print $input->dump;


print <<printend

<FONT SIZE=6><em>Requesting: <a href=biblio.html>$dat->{'title'}</a> ($dat->{'author'})</em></FONT><P>
<p>

<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=187 BORDER=0 src="/images/place-request.gif" align=right >

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left >

<!----------------BIBLIO RESERVE TABLE-------------->

<p align=right>
<form action="reserve.pl" method=post>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
</TR>
<tr VALIGN=TOP  >
        <TD><select name=rank-request>
	        <option value=1>1
		        <option value=2>2
			        <option value=3>3
				        <option value=4 selected >4
					        </select>
						        </td>
							
							        <TD><input type=text size=20 name=member></td>
								        <TD>1/01/00</td>
									
									
									        
										
										        <TD><select name=pickup>
											        <option value=levin>Levin
												        <option value=foxton>Foxton
													        <option value=Shannon>Shannon
														        </select>
															        </td>
																        
																	
																	        <td><input type=checkbox name=request value=any>Next Available, <br>(or choose from list below)</td>
																		</tr>
																		
																		
																		</table>
																		</p>
																		
																		
																		<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
																		
																		
																		
																		
																		
																		
																		<TR VALIGN=TOP>
																		
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Item Type</b></TD>
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Classification</b></TD>
																		
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Volume</b></TD>
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Number</b></TD>
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Copyright</b></TD>
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pubdate</b></TD>
																		<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Copies</b></TD>
																		</TR>
																		
																		
																		<tr VALIGN=TOP  >
																		
																		        <TD><input type=checkbox name=request value=bionumber>
																			        </td>
																				
																				        <TD>Large Print</td>
																					
																					
																					        <TD>Adult
																						        </td>
																							        
																								
																								        <td>1</td>
																									        <td>1</td>
																										        <td>1997</td>
																											        <td>1999</td>
																												        <td>LO123456, available F</td>
																													</tr>
																													
																													
																													
																													
																													<tr VALIGN=TOP  >
																													
																													        <TD><input type=checkbox name=request value=bionumber>
																														        </td>
																															
																															        <TD>Adult Fiction</td>
																																        <TD>Adult
																																	        </td>
																																		        
																																			
																																			        <td>1</td>
																																				        <td>1</td>
																																					        <td>1997</td>
																																						        <td>1999</td>
																																							        <td>LO123457, due 1/2/00</td>
																																								</tr>
																																								
																																								
																																								
																																								
																																								
																																								
																																								</table>
																																								</p>
																																								
																																								<p>&nbsp; </p>
																																								<!-----------MODIFY EXISTING REQUESTS----------------->
																																								
																																								<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
																																								
																																								<TR VALIGN=TOP>
																																								
																																								<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=6><B>MODIFY EXISTING REQUESTS </b></TD>
																																								</TR>
																																								
																																								<TR VALIGN=TOP>
																																								
																																								<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
																																								<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member</b></TD>
																																								<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
																																								
																																								<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
																																								<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
																																								<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Change To</b></TD>
																																								</TR>
																																								
																																								<tr VALIGN=TOP  >
																																								
																																								        <TD><select name=rank-request>
																																									        <option value=1>1
																																										        <option value=2>2
																																											        <option value=3>3
																																												        <option value="">Del
																																													        </select>
																																														        </td>
																																															
																																															        <TD><a href=/members/rachey-record.html>Rachey Hamilton-Williams</a></td>
																																																        <TD>1/2/00</td>
																																																	
																																																	
																																																	        
																																																		        <TD><select name=pickup>
																																																			        <option value=levin>Levin
																																																				        <option value=foxton>Foxton
																																																					        <option value=Shannon>Shannon
																																																						        </select>
																																																							        </td>
																																																								        
																																																									<TD>Next Available</td>
																																																									
																																																									<TD><select name=itemtype>
																																																									        
																																																										        <option value=next>Next Available
																																																											        <option value=change>Change Selection
																																																												        <option value=nc >No Change
																																																													        </select>
																																																														        </td>
																																																															        
																																																																</tr>
																																																																
																																																																
																																																																
																																																																<tr VALIGN=TOP  >
																																																																
																																																																        <TD><select name=rank-request>
																																																																	        <option value=1>1
																																																																		        <option value=2 selected>2
																																																																			        <option value=3>3
																																																																				        <option value="">Del
																																																																					        </select>
																																																																						        </td>
																																																																							
																																																																							        <TD><a href=/members/rachey-record.html>Tod Jones</a></td>
																																																																								        <TD>1/2/00</td>
																																																																									
																																																																									        
																																																																										        <TD><select name=pickup>
																																																																											        <option value=levin>Levin
																																																																												        <option value=foxton>Foxton
																																																																													        <option value=Shannon>Shannon
																																																																														        </select>
																																																																															        </td>
																																																																																        
																																																																																	
																																																																																	<TD>#23458</td>
																																																																																	
																																																																																	<TD><select name=itemtype>
																																																																																	        
																																																																																		        <option value=next>Next Available
																																																																																			        <option value=change>Change Selection
																																																																																				        <option value=nc >No Change
																																																																																					        </select>
																																																																																						        </td>
																																																																																							</tr>
																																																																																							
																																																																																							
																																																																																							<tr VALIGN=TOP  >
																																																																																							
																																																																																							        <TD><select name=rank-request>
																																																																																								        <option value=1>1
																																																																																									        <option value=2>2
																																																																																										        <option value=3 selected >3
																																																																																											        <option value="">Del
																																																																																												        </select>
																																																																																													        </td>
																																																																																														
																																																																																														        <TD><a href=/members/rachey-record.html>Freida Daggeral</a></td>
																																																																																															        <TD>1/2/00</td>
																																																																																																        
																																																																																																	
																																																																																																	        
																																																																																																		<TD><select name=pickup>
																																																																																																		        <option value=levin>Levin
																																																																																																			        <option value=foxton selected>Foxton
																																																																																																				        <option value=Shannon>Shannon
																																																																																																					        </select>
																																																																																																						        </td>
																																																																																																							        
																																																																																																								<TD>#23458</td>
																																																																																																								
																																																																																																								<TD><select name=itemtype>
																																																																																																								        
																																																																																																									        <option value=next>Next Available
																																																																																																										        <option value=change>Change Selection
																																																																																																											        <option value=nc >No Change
																																																																																																												        </select>
																																																																																																													        </td>
																																																																																																														
																																																																																																														
																																																																																																														</tr>
																																																																																																														
																																																																																																														
																																																																																																														
																																																																																																														
																																																																																																														<tr VALIGN=TOP  >
																																																																																																														
																																																																																																														        <TD colspan=6 align=right>
																																																																																																															Delete a request by selcting "del" from the rank list.
																																																																																																															
																																																																																																															<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=64 BORDER=0 src="/images/ok.gif"></td>
																																																																																																															
																																																																																																															        </tr>
																																																																																																																
																																																																																																																
																																																																																																																</table>
																																																																																																																<P>
																																																																																																																<br>
																																																																																																																
																																																																																																																
																																																																																																																
																																																																																																																
																																																																																																																</form>
																																																																																																																
																																																																																																																
																																																																																																																

printend
;

print endmenu();
print endpage();
