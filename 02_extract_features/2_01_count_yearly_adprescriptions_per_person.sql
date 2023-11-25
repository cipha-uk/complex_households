/*** this is one of the scripts to extract features to include in the complex households dataset ***/

/****** Script to count antidepressant prescriptions for a given year ******/

/***  Author: Roberta Piroddi  ***/
/*** Date: 2022, 10   ***/
/*** Updated: 2023, 11 ***/

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

DECLARE @specificYear INT;
SET @specificYear = 2021


DROP TABLE if exists Client_SystemP_RW.RP_ADprescriptions_2021
SELECT  Pseudo_NHS_Number,
     COUNT(*) AS "Antidepressants"
	 INTO Client_SystemP_RW.RP_ADprescriptions_2021
     FROM Client_SystemP_RW.RP201_ADprescriptions
     WHERE YEAR(MedicationDate) = @specificYear
    
GROUP BY	
Pseudo_NHS_Number 
                     
