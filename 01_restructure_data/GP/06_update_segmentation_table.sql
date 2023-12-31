/****** This code is based on Justine Wiltshire code
******/

/*** Updates author: Roberta Piroddi  ***/
---------------------------------------------------------------------------------------------------------------------------------------------

/****** Script to update Population Segmentation tables from Complex lives indicators  ******/

/*
-------------------------------------------------------------------------------------------------------------
This software is released under the GNU GENERAL PUBLIC license. See the LICENSE file for details.

THIS SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT 
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. 

IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH 
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

You acknowledge and agree that the use of this software is at your own risk, and the authors disclaim 
any and all liability for any direct, indirect, incidental, consequential, or special damages or losses 
that may result from the use or inability to use the software.
-------------------------------------------------------------------------------------------------------------
*/

-------------------------------------------------------------------------------------------------------------------------------------------------
/*MAIN FILE AND UPDATES*/
-------------------------------------------------------------------------------------------------------------------------------------------------
update A 
set A.Complex = B.Complex
	,A.Homeless = B.Homeless
	,A.H_abuse = B.H_abuse
	,A.offender = B.offender
	,A.Substance_or_alcohol = B.Substance_or_alcohol
	,A.Alcohol = B.Alcohol
	,A.substance = B.substance
	,A.freq_ae_attend = B.freq_ae_attend
	,A.h_looked_after = B.h_looked_after
from Client_SystemP_RW.RP103_Segmentation as A
inner join Client_SystemP_RW.RP104_Complex as B
	on A.Pseudo_NHS_Number=B.Pseudo_NHS_Number



update Client_SystemP_RW.RP103_Segmentation
set Segment = case when [Palliative_EOL_Reg] = 1 then 'End of Life'
					when [Frailty_or_Dementia] = 1 then	'Frailty/Dementia'
					when [Complex] = 1 then	'Complex Lives'
					when [Cancer] = 1 then 'Cancer'
					when [LTC] = 1 then 'LTCs'
					when [Precondition] = 1 then 'Pre-conditions'
					when [Learning_Disabilities] = 1 then 'Learning Disabilities'
					when [Physical_Disability] = 1 then	'Physical Disabilities'
					else 'Healthy' end --as [Dominant Segment]

