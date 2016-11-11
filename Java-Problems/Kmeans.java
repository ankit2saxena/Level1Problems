package kmeans;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Random;

/**
 * k-means algorithm 
 * The program runs for k = 2 to 5 and calculates the error rate for every value of k.
 * k = number of desired Centroids, clusters
 * dmetric(Element A, Element B) returns the distance between two data points
 * threshold is defined as a double
 * delta is defined as the collection of input data points
 * c_array is defined the collection of Centroids
 */

public class Kmeans {

	static int k = 2;	//number of clusters or centroids
	static int params_count = 8;	//number of parameters to be taken as input for clustering
	static int iteration = 10;		//number of iterations (centroid calculation will stop after this)
	static double threshold = 6.0f;	//expected value of threshold (centroid calculation will stop after the calculated threshold falls below expected value)
	static ArrayList <Element> delta = new ArrayList<Element>();
	static ArrayList <Centroid []> c = new ArrayList<Centroid[]>();
	static int loop_counter = 0;
	static Element domain_min = new Element(params_count);
	static Element domain_max = new Element(params_count);
	static double sum_Thresh = 0;
	
	public static void main(String[] args) {
		
		try {
			FileReader fr = new FileReader(new File("C:\\Users\\Ankit\\Documents\\DeltaClean2.txt"));	//Path of Input Data
			BufferedReader br = new BufferedReader(fr);
			
			FileWriter fw = new FileWriter(new File("C:\\Users\\Ankit\\Documents\\k_error_rate.txt"));	//Path of Output Data containing Error Rate for different values for k
			BufferedWriter bw = new BufferedWriter(fw);
			
			bw.write("K,Error_Rate");
			bw.newLine();
			
			String line = "";
			Centroid [] c_array = null;
			Element random_in_range = new Element(params_count);
			ArrayList <Element> tempB = null;
			String [] tempSArray = null;
			double [] tempDArray = new double[params_count];
			float [] sum_b = new float[k];
			float [] sum_m = new float[k];
			float error_rate = 0.0f;
			
			while((line = br.readLine()) != null) {
				tempSArray = line.split(",");
				for(int i = 1; i < tempSArray.length-1; i++) {
					if("?".equals(tempSArray[i]) || "".equals(tempSArray[i]) )
						tempDArray[i-1] = 0.0;
					else
						tempDArray[i-1] = Double.parseDouble(tempSArray[i]);
				}
				Element tempEle = new Element(params_count,tempDArray);
				tempEle.setScn(tempSArray[0]);
				tempEle.setC(Integer.parseInt(tempSArray[params_count+1]));
				delta.add(tempEle);
				tempDArray = new double[params_count];
			}
			
			findDomain(params_count);
			
			while(k<=5) {
				for(int req = 0; req < 20; req++) {
					System.out.println("Number of Centroids: " + k);
					loop_counter = 0;
					c_array = new Centroid[k];
					int small_B = 0;
					double [] arr = new double[k]; 
					
					for(int i = 0; i < k ; i++) {
						c_array[i] = new Centroid(params_count);
					}
					
					System.out.println("Input Data: " + delta.size() + " records fetched.");
					/*for(Element values: delta) {
						System.out.println(values.toString());
					}*/
					System.out.println();
					
					System.out.println("Min: " + domain_min + ", Max: " + domain_max);
					System.out.println();
					
					c.add(c_array);
					for(int j = 0; j < k; j++) {
						for(int i = 0; i < params_count; i++) {
							double tempRandom = (new Random().nextInt((int)(domain_max.getParams()[i]-domain_min.getParams()[i]))+domain_min.getParams()[i]);
							random_in_range.setParams(i, tempRandom);
						}
						c.get(loop_counter)[j].setV(random_in_range);
						c.get(loop_counter)[j].setB(new ArrayList<Element>());
						random_in_range = new Element(params_count);
					}	
						
					System.out.print("Iteration " + (loop_counter+1) + ": ");
					for(int i = 0; i < k; i++) {
						 System.out.print(c.get(loop_counter)[i] + ", ");
					}
					
					System.out.println();
					
					while(++loop_counter < iteration) {
						c_array = new Centroid[k];
						for(int j = 0; j < k ; j++) {
							c_array[j] = new Centroid(params_count);
						}
						c.add(c_array);
						for(Element e: delta) {
							for(int j = 0; j < k; j++) {
								arr[j] = dmetric(e, c.get(loop_counter-1)[j].getV());
							}
							small_B = findSmallestDis(arr);
							c.get(loop_counter)[small_B].getB().add(e);
							
						}
						for(int j = 0; j < k; j++) {
							c.get(loop_counter)[j].setV(calCentroidByAvg(c.get(loop_counter)[j].getB()));
						}
						
						System.out.print("Iteration " + (loop_counter+1) + ": ");
						
						for(int i = 0; i < k; i++) {
							 System.out.print(c.get(loop_counter)[i] + ", ");
						}
						
						System.out.println();
						
						for(int j = 0; j < k; j++) {
							sum_Thresh += dmetric(c.get(loop_counter-1)[j].getV(), c.get(loop_counter)[j].getV());
						}
						System.out.println("******Threshold******" + sum_Thresh/k);
						
						if(sum_Thresh/k < threshold)
							break;
						
						br.close();
					}
					
					sum_b = new float[k];
					sum_m = new float[k];
					error_rate = 0.0f;
					
					for(int i = 0; i < k; i++) {
						tempB = c.get(loop_counter-1)[i].getB();
						System.out.println("Number of Elements: " + tempB.size());
		
						if(tempB.isEmpty()) {
							System.out.println("Empty Partition. Centroid " + (i+1));
							continue;
						}
						
						for(Element e: tempB) {
							if(e.getC() == 2)
								sum_b[i] += 1;
							if(e.getC() == 4)
								sum_m[i] += 1;
						}
						
						if(sum_b[i] >= sum_m[i]) {
							c.get(loop_counter-1)[i].getV().setC(2);
							System.out.println("Error Rate for Centroid " + (i+1) + ": " + (sum_m[i]/(sum_m[i] + sum_b[i])) + ", Centroid Class: benign (2)");
							error_rate += (sum_m[i]/(sum_m[i] + sum_b[i]));
						}
							
						if(sum_m[i] > sum_b[i]) {
							c.get(loop_counter-1)[i].getV().setC(4);
							System.out.println("Error Rate for Centroid " + (i+1) + ": " + (sum_b[i]/(sum_m[i] + sum_b[i])) + ", Centroid Class: malignant (4)");
							error_rate += (sum_b[i]/(sum_m[i] + sum_b[i]));
						}
					}
					
					System.out.println("Total Error Rate: " + error_rate);
					
					bw.write(new String(k + "," + error_rate));
					bw.newLine();
					c = new ArrayList<Centroid[]>();
				}
				k++;
			}
			br.close();
			fr.close();
			bw.close();
			fw.close();
			
		} catch (IOException e1) {
			e1.printStackTrace();
		}
		
	}
	
	/**
	 * To find the distance between Element A and Element B
	 */
	public static double dmetric(Element A, Element B) {
		
		double sum = 0.0;
		for(int i = 0; i < params_count; i++) {
			sum += Math.pow((A.getParams()[i] - B.getParams()[i]),2);
		}
		return Math.sqrt(sum);
	}
	
	/**
	 * To find the centroid ID which has the smallest distance to the input Element
	 */
	public static int findSmallestDis(double [] arr) {
		int i = 0;
		for(int j = 0; j < arr.length-1; j++) {
			if(arr[i] >= arr[j+1])
				i = j+1;
		}
		return i;
		
	}
	
	/**
	 * To calculate the centroid by the taking the average of all the elements in that Cluster
	 */
	public static Element calCentroidByAvg(ArrayList <Element> B) {
		Element temp_e = new Element(params_count);
		double [] sum = new double[params_count];
		
		if(B.isEmpty())
			return temp_e;
		
		for(int k = 0; k < params_count; k++) {
			for(int i = 0; i < B.size(); i++) {
				sum[k] += B.get(i).getParams()[k]; 
			}
			temp_e.setParams(k, sum[k]/B.size());
		}
		return temp_e;
	}
	
	/**
	 * To calculate the range (minimum and maximum) of all the input attributes
	 * pc_counter denotes the number of input parameters.  
	 */
	public static void findDomain(int pc_counter) {
		
		double [] arr_min = new double[pc_counter];
		double [] arr_max = new double[pc_counter];
		
		for(int i = 0; i < pc_counter; i++) {
			
			arr_min[i] = delta.get(0).getParams()[i];;
			arr_max[i] = delta.get(0).getParams()[i];
			
			for(int j = 0 ; j < delta.size(); j++) {
				
				if(arr_min[i] > delta.get(j).getParams()[i])
					arr_min[i] = delta.get(j).getParams()[i];
				
				if(arr_max[i] <= delta.get(j).getParams()[i])
					arr_max[i] = delta.get(j).getParams()[i];
								
			}
			
			domain_min = new Element(pc_counter, arr_min);
			domain_max = new Element(pc_counter, arr_max);
		}
	}

}

/**
 * 
 */
class Element {
	
	public Element(int pc) {
		params = new double[pc];
		for(int i =0; i < pc; i++) {
			params[i] = 0.0;
		}
	}
	
	public Element(int pc, double [] params) {
		this.params = new double [pc];
		this.params = params;
	}
	
	public double[] getParams() {
		return params;
	}
	
	public void setParams(int c, double value) {
		params[c] = value;
	}
	
	public void setParams(double[] params) {
		this.params = params;
	}
	
	public String getScn() {
		return scn;
	}

	public void setScn(String scn) {
		this.scn = scn;
	}

	public int getC() {
		return c;
	}

	public void setC(int c) {
		this.c = c;
	}

	public String toString() {
		StringBuilder retString = new StringBuilder();
		retString.append("{");
		for(int i = 0 ; i < params.length; i++) {
			if(i < (params.length - 1))
				retString.append(params[i] + ",");
			else
				retString.append(params[i]);
		}
		retString.append("}");
		
		return retString.toString();
	}

	private double [] params;
	private String scn;
	private int c;
	
}


/**
 * Centroid represents a cluster having a Centroid (an Element) along with an associated ArrayList of Elements, that belong to the cluster.
 */
class Centroid {
	
	public Centroid(int pc) {
		this.v = new Element(pc);
		this.B = new ArrayList<Element>();
	}
	
	public String toString() {
		return "{v:" + this.v.toString() + ", B:" + "}";
	}
	
	public Element getV() {
		return v;
	}
	public void setV(Element v) {
		this.v = v;
	}
	public ArrayList<Element> getB() {
		return B;
	}
	public void setB(ArrayList<Element> b) {
		B = b;
	}

	private Element v;
	private ArrayList <Element> B;
	
}