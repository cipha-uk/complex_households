/****** This is scripts adds some more conditions from the conditions table
these are important for the kind of analysis of complex households since it is
about children and families. This is an example of how to add other variables of interest
from the conditions table - in this case [RP102_Conditions]
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

DROP TABLE if exists [Client_SystemP_RW].[RP007_SPHD_2]

SELECT P.*
      
	   ,(CASE WHEN C.[Attention_Deficit_Hyperactivity_Disorder_MAX]
	    is not null THEN 1 ELSE 0 END +
        CASE WHEN C.[AUTISM_MAX]
		is not null THEN 1 ELSE 0 END) as 'neurodevelopmental'
     
  
INTO  [Client_SystemP_RW].[RP007_SPHD_2] 
FROM  [Client_SystemP_RW].[RP007_SPHD_1] P


INNER JOIN [Client_SystemP_RW].[RP102_Conditions] C
ON P.[Pseudo_NHS_Number] = C.[Pseudo_NHS_Number]  
  

