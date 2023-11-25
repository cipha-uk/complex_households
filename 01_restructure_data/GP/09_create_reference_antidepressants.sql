/****** Script to create antidepressant reference ******/
/*** links cipha meds ids with bnf codes   ***/

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



   SELECT B.*
     ,S.PK_Reference_SnomedCT_ID
     ,S.ConceptID
  INTO Client_SystemP_RW.RP_ref_ad_meds
  FROM Client_SystemP_RW.RP_ref_bnf_snomed_map B
  INNER JOIN Client_SystemP.Reference_SnomedCT S
  ON B.SNOMED_Code=S.ConceptID
  WHERE B.BNF_Code LIKE '0403%'
 
  