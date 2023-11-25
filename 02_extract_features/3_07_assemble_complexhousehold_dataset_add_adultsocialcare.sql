/****** This is scripts adds more of the event features:
yearly
usage of adult social care services and their reason and cost

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

DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_7]

SELECT P.*
        ,ASC2.*
       ,A.[asc_services_12]
      ,A.[asc_cost_12]
      ,A.[asc_service_reason_physical_12]
      ,A.[asc_service_reason_mental_12]
      ,A.[asc_service_reason_substance_12]
      ,A.[asc_service_reason_social_12]
      ,A.[asc_service_reason_learning_12]
      ,A.[asc_service_reason_sensorycognition_12]
      ,A.[asc_service_reason_carer_12]

INTO  [Client_SystemP_RW].[RP007_SPHD_7] 
FROM  [Client_SystemP_RW].[RP007_SPHD_6] P

LEFT JOIN [Client_SystemP_RW].[RP_ASC_Services_2021] A
ON P.[Pseudo_NHS_Number] = A.[Pseudo_NHS_Number]



LEFT JOIN [Client_SystemP_RW].[RP_ASC_Requests_2021]  ASC2
ON P.[Pseudo_NHS_Number] = ASC3.[Pseudo_NHS_Number]

