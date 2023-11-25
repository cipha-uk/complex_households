/****** This is scripts adds more of the event features:
yearly
usage of several mental health services form MHSDS: referrals, contacts and reasons for referral

******/

/*** Author: Roberta Piroddi ***/
/*** Created: 2022,11 ***/
/*** Updated:2023,11 ***/

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

DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_5]

SELECT P.*
      ,MH_AE1.*
	       
		  
INTO  [Client_SystemP_RW].[RP007_SPHD_5] 
FROM  [Client_SystemP_RW].[RP007_SPHD_4] P

LEFT JOIN [Client_SystemP_RW].[RP_MHSDS_Referrals_reasons_carecontacts_2021] MH_AE1
ON P.[Pseudo_NHS_Number] = MH_AE1.[CM_PSEUDONYM]



 
      
  