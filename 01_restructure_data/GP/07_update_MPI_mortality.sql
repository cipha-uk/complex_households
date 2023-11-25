
/*** Author: Roberta Piroddi  ***/
---------------------------------------------------------------------------------------------------------------------------------------------
/* This script links mortality records to MPI */
---------------------------------------------------------------------------------------------------------------------------------------------
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

SELECT P.*
      ,[REG_DATE_OF_DEATH] as Date_of_Death
      ,[DEC_OCC_TYPE] as Dec_occupation
      ,[POD_CODE] as Place_of_Death_Code
      ,[POD_NHS_ESTABLISHMENT] as Place_of_Death_NHS_Establishment
      ,[POD_ESTABLISHMENT_TYPE] as Place_of_Death_Establishment_Type
      ,[S_UNDERLYING_COD_ICD10] as Underlying_Cause_of_Death
      ,[S_COD_CODE_1] as Primary_Cause_of_Death
      ,[S_COD_CODE_2] as Secondary_Cause_of_Death
  INTO Client_SystemP_RW.RP002_MPI
  FROM Client_SystemP_RW.RP001_MPI P
  LEFT JOIN [Client_ICS].[vw_Mortality] M
  ON  P.Pseudo_NHS_Number = M.DEC_NHS_NUMBER