int gcd(int a, int b) 
{
    while (b != 0) 
    {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

int main() 
{
    int num1, num2;
    int gcd;

    gcd = gcd(num1, num2);

    return 0;
}
