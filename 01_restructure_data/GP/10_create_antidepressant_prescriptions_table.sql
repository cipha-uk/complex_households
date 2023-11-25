/****** Script to select on a specific class of medications - antidepressants in this case
from cipha [GP_Medications] ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/

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

DROP TABLE if exists Client_SystemP_RW.RP201_ADprescriptions

SELECT M.FK_Patient_ID
      ,M.MedicationDate
      ,M.RepeatMedicationFlag
      ,M.FK_Patient_Link_ID
      ,M.FK_Reference_SnomedCT_ID
      ,M.X_CCG_OF_REGISTRATION
      ,M.X_CCG_OF_RESIDENCE
      ,AD.*
      ,P.[Pseudo_NHS_Number]
      ,P.[Sex]
      ,P.[Dob]
  INTO Client_SystemP_RW.RP201_ADprescriptions
  FROM [Client_SystemP].[GP_Medications] M
  INNER JOIN Client_SystemP_RW.RP_ref_ad_meds AD
  ON M.[FK_Reference_SnomedCT_ID]=AD.PK_Reference_SnomedCT_ID
  LEFT JOIN [Client_SystemP].[Patient] P
  ON  M.FK_Patient_ID = P.PK_Patient_ID
  WHERE P.Pseudo_NHS_Number is not null AND
        P.FK_Reference_Tenancy_ID = 2

