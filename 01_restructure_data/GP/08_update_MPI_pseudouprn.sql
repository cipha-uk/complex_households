
/*** Author: Roberta Piroddi  ***/
---------------------------------------------------------------------------------------------------------------------------------------------
/* this links the table with pseudo-uprns with the mpi */
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
      ,U.Der_Pseudo_UPRN as pUPRN
      ,U.living_with_over_64_flag
      ,U.Rural_Urban_Classification
      ,U.property_type
      ,U.OS_Property_Classification
  INTO Client_SystemP_RW.RP003_MPI
  FROM Client_SystemP_RW.RP002_MPI P
  LEFT JOIN [Client_SystemP].[PDS_UPRN_Indicators] U
  ON  P.Pseudo_NHS_Number = U.Der_Pseudo_NHS_Number