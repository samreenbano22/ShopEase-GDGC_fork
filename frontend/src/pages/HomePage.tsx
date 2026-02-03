import { Link } from 'react-router-dom';
import { Button } from '../components/ui/button';
import { Card, CardContent } from '../components/ui/card';

export function HomePage() {
  return (
    <div className="min-h-screen pb-20 md:pb-0 md:pt-20">
      <section className="py-20 px-4 text-center">
        <h1 className="text-4xl md:text-6xl font-bold mb-6">
          Welcome to <span className="text-primary">ShopEase</span>
        </h1>
        <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
          Discover amazing products at unbeatable prices. Shop with confidence and enjoy fast delivery.
        </p>
        <Link to="/products">
          <Button size="lg">Browse Products</Button>
        </Link>
      </section>

      <section className="py-16 px-4 max-w-4xl mx-auto">
        <h2 className="text-2xl font-bold mb-8 text-center">Why Choose Us</h2>
        <div className="grid md:grid-cols-3 gap-6">
          {[
            { title: 'Fast Delivery', desc: 'Get your orders delivered within 2-3 days' },
            { title: 'Secure Payment', desc: '100% secure payment processing' },
            { title: 'Easy Returns', desc: '30-day hassle-free return policy' },
          ].map((feature, i) => (
            <Card key={i}>
              <CardContent className="p-6 text-center">
                <h3 className="text-xl font-semibold mb-2">{feature.title}</h3>
                <p className="text-muted-foreground">{feature.desc}</p>
              </CardContent>
            </Card>
          ))}
        </div>
      </section>
    </div>
  );
}
