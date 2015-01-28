import org.jacop.constraints.*;
import org.jacop.core.*;
import org.jacop.search.*;


public class UrbanPlanning {
	private static int n = 5;
	private static int resident = 0;
	private static int commercial = 1;
	private static int numberOfCommercials = commercial*13;
	private static int nLines = 2*n;
	
	
	public static void main(String args[]) {
		//plan();
		planWithElement();
	}
	
	static void planWithElement() {
		// Init store
		Store store = new Store();
		
		// Init grid
		IntVar[] grid = new IntVar[n*n];
		for (int i = 0; i < n; i++) {
			for (int j = 0; j < n; j++) {
				grid[i*n + j] = new IntVar(store,"(" + i + "," + j + ")", resident, commercial);
			}
		}
		
		// Init lines
		IntVar[][] lines = new IntVar[nLines][n];
		for (int i = 0; i < n; i++) {
			//Find one row and one column
			lines[i]   = new IntVar[n];
			lines[i+n] = new IntVar[n];
			for (int j = 0; j < n; j++) {
				lines[i][j]   = grid[i*n + j];
				lines[i+n][j] = grid[i + n*j];
			}
		}
		
		// Init cost
		IntVar cost = new IntVar(store, "cost", -50, 50);

		// Impose constraint 12 residents
		IntVar maxCommercials = new IntVar(store, "sum", numberOfCommercials, numberOfCommercials);
		store.impose(new Sum(grid, maxCommercials));
		
		// Sum over each line
		IntVar lineSums[] = new IntVar[nLines];
		IntVar realSums[] = new IntVar[nLines];
		int[] values = {-5, -4, -3, 3, 4, 5};
		for (int i = 0; i < nLines; i++) {
			// Init sum variable
			lineSums[i] = new IntVar(store, "line sum " + i, 0, n);
			realSums[i] = new IntVar(store, "line sum w/ real vals " + i, -5, 5);
			
			// Map to values
			store.impose(new Element(lineSums[i], values, realSums[i], -1));
			
			// Constrain sum
			store.impose(new Sum(lines[i], lineSums[i]));
		}
		
		// Final sum
		store.impose(new Sum(realSums, cost));
		
		// Find solution on IntVar[][] grid, minimizing IntVar cost
		System.out.println();
		Search<IntVar> search = new DepthFirstSearch<IntVar>();
		//SelectChoicePoint <IntVar> select = new InputOrderSelect <IntVar>(store, grid, new IndomainMin<IntVar>());
		SelectChoicePoint <IntVar> select = new SimpleSelect <IntVar>(grid, new MostConstrainedStatic<IntVar>(),new IndomainMax<IntVar>());

		search.setSolutionListener(new PrintOutListener<IntVar>());
		boolean result = search.labeling(store, select, cost);

		if (result) {
			System.out.println("*** Solution ***");
			//System.out.println(store);
			
			for (int i = 0; i < n; i++) {
				for (int j = 0; j < n; j++) {
					System.out.print(grid[i*n + j].value());
				}
				System.out.println();
			}
		}
		
		
	}
	
	static void plan() {
		// 0 = residential lot, 1 = commercial lot
		Store store = new Store();

		// Setup grid of lots
		IntVar[] grid = new IntVar[n*n];
		for (int i = 0; i < n; i++) {
			for (int j = 0; j < n; j++) {
				grid[i*n + j] = new IntVar(store,"(" + i + "," + j + ")", resident, commercial);
			}
		}
		
		// Impose constraint 12 residents
		IntVar sum = new IntVar(store, "sum", numberOfCommercials, numberOfCommercials);
		store.impose(new Sum(grid, sum));
		
		// Init score values
		IntVar fives = new IntVar(store, "fives", 0, 2*n);
		IntVar fours = new IntVar(store, "fours", 0, 2*n);
		IntVar threes = new IntVar(store, "threes", 0, 2*n);
		IntVar mFives = new IntVar(store, "mFives", 0, 2*n);
		IntVar mFours = new IntVar(store, "mFours", 0, 2*n);
		IntVar mThrees = new IntVar(store, "mThrees", 0, 2*n);
				
		IntVar cost = new IntVar(store, "cost", -5*2*n, 5*2*n);
		
		IntVar[] resInRows = new IntVar[2*n];
		IntVar[] comInRows = new IntVar[2*n];
		for (int i = 0; i < n; i++) {

			IntVar[] row = new IntVar[n];
			IntVar[] col = new IntVar[n];
			for (int j = 0; j < row.length; j++) {
				row[j] = grid[i*n + j];
				col[j] = grid[i + n*j];
			}
			
			resInRows[i] = new IntVar(store, "resInRow" + i, 0, 5);
			store.impose(new Count(row, resInRows[i], 0));
			comInRows[i] = new IntVar(store, "comInRow" + i, 0, 5);
			store.impose(new Count(row, comInRows[i], 1));
			
			resInRows[i+n] = new IntVar(store, "resInRow" + (i+n), 0, 5);
			store.impose(new Count(col, resInRows[i+n], 0));
			comInRows[i+n] = new IntVar(store, "comInRow" + (i+n), 0, 5);
			store.impose(new Count(col, comInRows[i+n], 1));			

		}


		store.impose(new Count(resInRows, fives, 5));
		store.impose(new Count(resInRows, fours, 4));
		store.impose(new Count(resInRows, threes, 3));
		store.impose(new Count(comInRows, mFives, 5));
		store.impose(new Count(comInRows, mFours, 4));
		store.impose(new Count(comInRows, mThrees, 3));
		IntVar[] nums = new IntVar[] {fives,fours,threes,mFives,mFours,mThrees};
		int[] numWeights = new int[] {-5,-4,-3,5,4,3};
		store.impose(new SumWeight(nums, numWeights, cost));
		

		
		Search<IntVar> search = new DepthFirstSearch<IntVar>();
		SelectChoicePoint <IntVar> select = new InputOrderSelect <IntVar>(store, grid, new IndomainMin<IntVar>());
		search.labeling(store, select, cost);

		
	}
}
