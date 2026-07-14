# Reportplay

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://phoenix.hexdocs.pm/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://phoenix.hexdocs.pm/overview.html
* Docs: https://phoenix.hexdocs.pm
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix


```css
@page { size: A3; }
@page { size: A4; }
@page { size: A5; }
@page { size: B4; }
@page { size: B5; }
@page { size: letter; } /* 8.5in x 11in */
@page { size: legal; }  /* 8.5in x 14in */
@page { size: ledger; } /* 11in x 17in */
@page { size: A4 landscape; }
@page { size: letter portrait; }
@page { size: 54mm 86mm; }   /* Standard CR80 ID Card */
@page { size: 80mm 250mm; }  /* POS Thermal Receipt */
@page { size: 4in 6in; }     /* Shipping Label */
@page { margin: 0; }                  /* Blank canvas (Recommended for Tailwind) */
@page { margin: 20mm; }               /* 20mm on all 4 sides */
@page { margin: 25mm 15mm; }          /* Top/Bottom 25mm, Left/Right 15mm */
@page { margin: 10mm 15mm 20mm 15mm; } /* Top, Right, Bottom, Left */
@page {
  size: A4;
  margin: 20mm;
}

@page :first {
  margin: 0;
}
@page :left {
  /* Binding is on the right side of a left-hand page */
  margin-left: 15mm;
  margin-right: 30mm; 
}

@page :right {
  /* Binding is on the left side of a right-hand page */
  margin-left: 30mm;
  margin-right: 15mm;
}
```