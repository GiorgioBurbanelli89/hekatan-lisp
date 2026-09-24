using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace HekatanLisp
{
    /// <summary>
    /// ANIMACIÓN y VOZ de la hoja (escritorio y web: el mismo C#, el mismo JS).
    ///
    ///   #anim fplot(…), n = 1:8                      una gráfica por valor del parámetro
    ///   #anim surf(expr, [0 1], [0 1]), k = 1:16     superficie (un solo lienzo que se gira; escala z común)
    ///   #anim surf(N, [0 1], [0 1])                  N matriz/vector de la hoja: un cuadro por componente
    ///   #anim map(expr, [0 1], [0 1]), k = 1:8       mapa de color
    ///   #anim(n = 2:2:16)  …  #finanim               BLOQUE: todo lo de dentro (#dibujo, #autolisp,
    ///                                                #surf, #map, texto, fórmulas) se repite por cuadro
    ///   #anim(n = 1:5) + #dibujo … #fin              forma corta: el bloque de dibujo que sigue
    ///   #voz: texto                                  narración (Web Speech API, voz es-*); pegada a una
    ///                                                animación = un texto por cuadro, en orden
    ///
    /// Los cuadros los calcula el motor de antemano; el JS solo enseña uno y esconde los demás
    /// (no hay matemática en el navegador). Sin voz en español el botón 🔊 no aparece y la
    /// animación sigue sola. Al imprimir (PDF) queda el cuadro 1 con su texto.
    /// </summary>
    public static class LispAnim
    {
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;
        public static string P(double v) => Math.Abs(v - Math.Round(v)) < 1e-9 ? Math.Round(v).ToString("0", Inv) : v.ToString("0.####", Inv);

        // ---------------------------------------------------------------- sintaxis
        /// <summary>#anim(n = 2:2:16) — la cabecera de un BLOQUE animado.</summary>
        public static readonly Regex RxBloque = new Regex(
            @"^\s*#\s*(?:anim|animar|animacion)\s*\(\s*([A-Za-z]\w*)\s*=\s*(-?[\d.]+)\s*:\s*(-?[\d.]+)\s*(?::\s*(-?[\d.]+))?\s*\)\s*$",
            RegexOptions.IgnoreCase);
        static readonly Regex RxFinBloque = new Regex(@"^\s*#\s*(?:fin\s*anim(?:acion)?|finanim(?:acion)?)\s*$", RegexOptions.IgnoreCase);
        static readonly Regex RxIniDib = new Regex(@"^\s*#\s*(?:dibujo|autolisp|dibujar)\b", RegexOptions.IgnoreCase);
        static readonly Regex RxFin = new Regex(@"^\s*#\s*fin(?:\s*dibujo|\s*autolisp|dibujo|autolisp)?\s*$", RegexOptions.IgnoreCase);
        /// <summary>#voz: texto  ·  #voz texto</summary>
        public static readonly Regex RxVoz = new Regex(@"^\s*#\s*voz\b\s*:?\s*(.*)$", RegexOptions.IgnoreCase);
        /// <summary>Marcadores que deja ExpandirBloques (se pintan como div vacío y los agrupa PostProcesar).</summary>
        public static readonly Regex RxMarca = new Regex(@"^\s*#hkan(fr|fin)\s+(\d+)\s+(\S+)\s*(.*)$");
        /// <summary>#anim plot(…), par = a:b — la línea de una animación de gráfica (para saber el parámetro de la voz).</summary>
        static readonly Regex RxAnimLinea = new Regex(@"^\s*#\s*(?:anim|animar|animacion)\b.*,\s*([A-Za-z]\w*)\s*=\s*-?[\d.]+\s*:[^,]*$", RegexOptions.IgnoreCase);
        static readonly Regex RxProsa = new Regex(@"^\s*#(\s|[:|=<>#]|voz\b)", RegexOptions.IgnoreCase);

        public static List<double> Valores(string a, string b, string c)
        {
            double va = double.Parse(a, Inv), vb = double.Parse(b, Inv), st = 1;
            if (!string.IsNullOrEmpty(c)) { st = vb; vb = double.Parse(c, Inv); }
            var vals = new List<double>();
            if (st <= 0 || vb < va) return vals;
            for (double v = va; v <= vb + st * 1e-9 && vals.Count < 60; v += st) vals.Add(Math.Round(v, 10));
            return vals;
        }

        /// <summary>Sustituye el parámetro por su valor: en la prosa solo {k} y @{k}; en el resto
        /// (fórmulas, directivas, líneas de #dibujo/#autolisp) también la palabra suelta k.</summary>
        public static string Sustituir(string linea, string par, string val, bool codigo)
        {
            string s = linea.Replace("@{" + par + "}", val).Replace("{" + par + "}", val);
            if (!codigo) return s;
            return Regex.Replace(s, @"(?<![\w.'])" + Regex.Escape(par) + @"(?![\w'(])", val);
        }

        /// <summary>Repite cada bloque #anim(par = a:b) … #finanim una vez por valor, con marcadores
        /// entre cuadro y cuadro. Va ANTES que todo lo demás del pipeline (cada copia se calcula como
        /// cualquier otra parte de la hoja).</summary>
        public static string ExpandirBloques(string text)
        {
            if (string.IsNullOrEmpty(text) || !Regex.IsMatch(text, @"(?im)^\s*#\s*anim(?:ar|acion)?\s*\(")) return text;
            var src = text.Replace("\r", "").Split('\n');
            var sal = new List<string>();
            int id = 0;
            for (int i = 0; i < src.Length; i++)
            {
                var m = RxBloque.Match(src[i]);
                if (!m.Success) { sal.Add(src[i]); continue; }
                var vals = Valores(m.Groups[2].Value, m.Groups[3].Value, m.Groups[4].Success ? m.Groups[4].Value : null);
                string par = m.Groups[1].Value;
                // extensión: forma corta (el #dibujo/#autolisp que sigue, hasta su #fin) o hasta #finanim
                int ini = i + 1, fin = -1; bool corta = false;
                int k0 = ini; while (k0 < src.Length && src[k0].Trim().Length == 0) k0++;
                int kf = -1;
                // el #finanim de ESTE bloque: se busca solo hasta la cabecera del siguiente #anim(…)
                for (int j = ini; j < src.Length; j++)
                {
                    if (RxBloque.IsMatch(src[j])) break;
                    if (RxFinBloque.IsMatch(src[j])) { kf = j; break; }
                }
                if (kf < 0 && k0 < src.Length && RxIniDib.IsMatch(src[k0]))
                {
                    for (int j = k0 + 1; j < src.Length; j++) if (RxFin.IsMatch(src[j])) { fin = j; break; }
                    if (fin < 0) fin = src.Length - 1;
                    corta = true;
                }
                else fin = kf < 0 ? src.Length : kf;
                int hasta = corta ? fin : fin - 1;          // última línea del cuerpo
                var cuerpo = new List<string>();
                for (int j = ini; j <= hasta && j < src.Length; j++) cuerpo.Add(src[j]);
                if (vals.Count == 0) { sal.AddRange(cuerpo); i = corta ? fin : Math.Min(fin, src.Length - 1); continue; }
                id++;
                for (int f = 0; f < vals.Count; f++)
                {
                    string v = P(vals[f]);
                    sal.Add("#hkanfr " + id + " " + f + " " + par + " = " + v);
                    bool enDib = false;
                    foreach (var l in cuerpo)
                    {
                        if (RxIniDib.IsMatch(l)) enDib = true;
                        bool codigo = enDib || !RxProsa.IsMatch(l);
                        sal.Add(Sustituir(l, par, v, codigo));
                        if (enDib && RxFin.IsMatch(l)) enDib = false;
                    }
                }
                sal.Add("#hkanfin " + id + " " + par);
                i = corta ? fin : Math.Min(fin, src.Length - 1);
            }
            return string.Join("\n", sal);
        }

        /// <summary>Marcador (línea #hkanfr / #hkanfin) → div vacío que PostProcesar reconoce.</summary>
        public static string MarcaHtml(Match m)
        {
            var enc = new Func<string, string>(System.Net.WebUtility.HtmlEncode);
            if (m.Groups[1].Value == "fin")
                return "<div class=\"hk-anmark\" data-id=\"" + m.Groups[2].Value + "\" data-fin=\"" + enc(m.Groups[3].Value) + "\"></div>";
            return "<div class=\"hk-anmark\" data-id=\"" + m.Groups[2].Value + "\" data-i=\"" + m.Groups[3].Value +
                   "\" data-lbl=\"" + enc((m.Groups[4].Value ?? "").Trim()) + "\"></div>";
        }

        static readonly Regex RxMarcaHtml = new Regex(
            "<div class=\"hk-anmark\" data-id=\"(\\d+)\" (?:data-i=\"(\\d+)\" data-lbl=\"([^\"]*)\"|data-fin=\"([^\"]*)\")></div>");

        /// <summary>Agrupa lo que hay entre marcadores (ya dibujado: SVG, lienzos, fórmulas…) en los
        /// cuadros de UN reproductor. Se llama con la página ya armada (escritorio y web).</summary>
        public static string PostProcesar(string html)
        {
            if (html == null || html.IndexOf("hk-anmark", StringComparison.Ordinal) < 0) return html;
            var ms = RxMarcaHtml.Matches(html).Cast<Match>().ToList();
            var sb = new StringBuilder();
            int pos = 0, k = 0;
            while (k < ms.Count)
            {
                var m0 = ms[k];
                if (!m0.Groups[2].Success) { k++; continue; }       // un fin suelto: se ignora
                string id = m0.Groups[1].Value;
                var frames = new List<string>(); var labels = new List<string>();
                string par = null;
                int j = k, finEnd = -1;
                while (j < ms.Count && ms[j].Groups[1].Value == id)
                {
                    var mj = ms[j];
                    int ini = mj.Index + mj.Length;
                    if (!mj.Groups[2].Success) { par = mj.Groups[4].Value; finEnd = ini; j++; break; }
                    int end = j + 1 < ms.Count ? ms[j + 1].Index : html.Length;
                    frames.Add(html.Substring(ini, end - ini));
                    labels.Add(System.Net.WebUtility.HtmlDecode(mj.Groups[3].Value));
                    j++;
                }
                sb.Append(html, pos, m0.Index - pos);
                if (par == null) par = labels.Count > 0 ? labels[0].Split('=')[0].Trim() : "k";
                sb.Append(Player(frames, labels, par, null, 1.2, "hkab" + id));
                pos = finEnd >= 0 ? finEnd : (j < ms.Count ? ms[j].Index : html.Length);
                k = j;
            }
            sb.Append(html, pos, html.Length - pos);
            return sb.ToString();
        }

        /// <summary>El parámetro de la animación a la que se pega una línea #voz (mirando hacia
        /// atrás: otras #voz y líneas vacías no cuentan). null = la voz va suelta.</summary>
        public static string ParDeVoz(string[] lines, int i)
        {
            for (int j = i - 1; j >= 0; j--)
            {
                var t = (lines[j] ?? "").Trim();
                if (t.Length == 0 || RxVoz.IsMatch(t)) continue;
                var mf = RxMarca.Match(t);
                if (mf.Success && mf.Groups[1].Value == "fin") return mf.Groups[3].Value;
                var ma = RxAnimLinea.Match(t);
                if (ma.Success) return ma.Groups[1].Value;
                if (Regex.IsMatch(t, @"^#\s*(?:anim|animar|animacion)\b", RegexOptions.IgnoreCase)) return "";
                return null;
            }
            return null;
        }

        /// <summary>Una línea #voz ya formateada (negrita, @{valores}…). Pegada a una animación queda
        /// oculta: el reproductor la toma como subtítulo del cuadro. Suelta: párrafo con 🔊.</summary>
        public static string VozHtml(string html, bool pegada)
        {
            if (pegada) return "<div class=\"hk-voz\" data-adj=\"1\" style=\"display:none\">" + html + "</div>";
            return "<div class=\"hk-voz ws-fmt al-left\" style=\"margin:.35em 0\"><button class=\"hk-voz-btn\" type=\"button\" " +
                   "title=\"Escuchar\" style=\"display:none;margin-right:.4em;border:1px solid var(--mut);background:transparent;" +
                   "color:var(--fg);border-radius:4px;cursor:pointer\">🔊</button><span class=\"hk-voz-txt\">" + html + "</span></div>" +
                   "<script>" + LibJs + "hkTarde(hkVozSuelta,document.currentScript.previousElementSibling);</script>";
        }

        // ---------------------------------------------------------------- reproductor
        /// <summary>Reproductor: cuadros superpuestos (solo uno visible), ▶/⏸, barra de cuadro,
        /// rótulo «k = 3 (3/16)», subtítulo y 🔊. voces: null = las toma el JS de las líneas #voz
        /// que siguen a la animación (o de las que hay dentro de cada cuadro).</summary>
        public static string Player(List<string> frames, List<string> labels, string par, List<string> voces,
                                    double dt, string id, string lienzo = null)
        {
            var enc = new Func<string, string>(System.Net.WebUtility.HtmlEncode);
            int n = lienzo != null ? labels.Count : frames.Count;
            var sb = new StringBuilder();
            sb.Append("<div class=\"hk-anim\" id=\"").Append(id).Append("\" data-n=\"").Append(n).Append("\" data-i=\"0\" data-par=\"")
              .Append(enc(par ?? "")).Append("\" data-dt=\"").Append((int)(dt * 1000)).Append("\" style=\"margin:1.1em 0;text-align:center\">");
            sb.Append("<div class=\"hk-anim-frames\" style=\"display:grid\">");
            if (lienzo != null)
                sb.Append("<div class=\"hkfr\" data-i=\"0\" style=\"grid-area:1/1\">").Append(lienzo).Append("</div>");
            else
                for (int i = 0; i < frames.Count; i++)
                    sb.Append("<div class=\"hkfr\" data-i=\"").Append(i).Append("\" style=\"grid-area:1/1;visibility:")
                      .Append(i == 0 ? "visible" : "hidden").Append("\">").Append(frames[i]).Append("</div>");
            sb.Append("</div>");
            sb.Append("<div class=\"hk-anim-lbl\" style=\"color:var(--fg);margin-top:.2em\">").Append(enc(labels.Count > 0 ? labels[0] : ""))
              .Append(" <span style=\"color:var(--mut);font-size:.85em\">(1/").Append(n).Append(")</span></div>");
            sb.Append("<div class=\"hk-anim-sub\" style=\"max-width:640px;margin:.35em auto 0;min-height:1.2em;color:var(--fg);font-size:.95em;line-height:1.35\"></div>");
            sb.Append("<div class=\"hk-anim-ctl\" style=\"display:flex;align-items:center;gap:.5em;max-width:560px;margin:.4em auto 0\">")
              .Append("<button class=\"hk-anim-play\" type=\"button\" title=\"Reproducir / pausa\" style=\"min-width:2.2em;border:1px solid var(--mut);background:transparent;color:var(--fg);border-radius:4px;cursor:pointer\">⏸</button>")
              .Append("<input class=\"hk-anim-bar\" type=\"range\" min=\"0\" max=\"").Append(Math.Max(0, n - 1)).Append("\" value=\"0\" step=\"1\" style=\"flex:1\">")
              .Append("<button class=\"hk-anim-voz\" type=\"button\" title=\"Escuchar la narración\" style=\"display:none;min-width:2.2em;border:1px solid var(--mut);background:transparent;color:var(--fg);border-radius:4px;cursor:pointer\">🔊</button>")
              .Append("</div>");
            // datos: rótulos (y voces si vienen del C#) — JSON en un <script type=application/json>
            sb.Append("<script type=\"application/json\" class=\"hk-anim-data\">{\"lbl\":[")
              .Append(string.Join(",", labels.Select(Js))).Append("]");
            if (voces != null) sb.Append(",\"voz\":[").Append(string.Join(",", voces.Select(Js))).Append("]");
            sb.Append("}</script>");
            sb.Append("<script>").Append(LibJs).Append("hkTarde(hkAnimInit,document.getElementById('").Append(id).Append("'));</script>");
            sb.Append("</div>");
            return sb.ToString();
        }

        static string Js(string s)
        {
            var b = new StringBuilder("\"");
            foreach (var c in s ?? "")
                switch (c)
                {
                    case '"': b.Append("\\\""); break;
                    case '\\': b.Append("\\\\"); break;
                    case '\n': b.Append("\\n"); break;
                    case '\r': break;
                    case '<': b.Append("\\u003c"); break;
                    case '>': b.Append("\\u003e"); break;
                    default: if (c < 32) b.Append(' '); else b.Append(c); break;
                }
            return b.Append('"').ToString();
        }

        /// <summary>El JS del reproductor y de la voz (se define una sola vez por página).</summary>
        /// En UNA línea: el pipeline parte la hoja por saltos de línea, y un salto dentro del
        /// &lt;script&gt; de una línea de texto (#voz suelta) partía el script y lo pintaba como fórmulas.
        public static readonly string LibJs = LibJsFuente.Replace("\r", "").Replace("\n", "");
        const string LibJsFuente = @"if(!window.hkAnimInit){(function(){
window.hkTarde=function(f,el){if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',function(){f(el);});else setTimeout(function(){f(el);},0);};
var S=window.speechSynthesis||null,VOZ=null,listos=[],buscada=false;
function elige(){if(!S)return null;var v=S.getVoices()||[],es=v.filter(function(x){return /^es([-_]|$)/i.test(x.lang||'');});
 return es.filter(function(x){return /^es[-_]ES/i.test(x.lang);})[0]||es[0]||null;}
window.hkVoz=function(cb){if(VOZ){cb(VOZ);return;}listos.push(cb);if(buscada)return;buscada=true;
 function fin(){var v=elige();VOZ=v;var l=listos;listos=[];l.forEach(function(f){f(v);});}
 if(!S){setTimeout(fin,0);return;}if(elige()){setTimeout(fin,0);return;}
 var hecho=false;S.addEventListener&&S.addEventListener('voiceschanged',function(){if(!hecho&&elige()){hecho=true;fin();}});
 setTimeout(function(){if(!hecho){hecho=true;fin();}},2500);};
window.hkHabla=function(txt,alFin){if(!S||!VOZ||!txt){if(alFin)alFin();return null;}S.cancel();
 var u=new SpeechSynthesisUtterance(txt);u.voice=VOZ;u.lang=VOZ.lang;u.rate=1;var ok=false;
 function f(){if(ok)return;ok=true;if(alFin)alFin();}u.onend=f;u.onerror=f;S.speak(u);return u;};
window.hkCalla=function(){if(S)S.cancel();};
function txt(el){var c=el.cloneNode(true);c.querySelectorAll('script,style,button').forEach(function(x){x.remove();});return (c.textContent||'').replace(/\s+/g,' ').trim();}
window.hkVozSuelta=function(d){if(!d)return;var b=d.querySelector('.hk-voz-btn'),t=d.querySelector('.hk-voz-txt');var on=false;
 hkVoz(function(v){if(v&&b)b.style.display='';});
 if(b)b.onclick=function(){if(on){on=false;hkCalla();b.textContent='🔊';return;}on=true;b.textContent='⏹';hkHabla(txt(t),function(){on=false;b.textContent='🔊';});};};
function vozDe(el){if(!el||el.nodeType!==1)return null;if(el.classList.contains('hk-voz')&&el.dataset.adj)return el;return null;}
window.hkAnimInit=function(R){if(!R||R.hkAnim)return;
 var fr=R.querySelectorAll(':scope > .hk-anim-frames > .hkfr'),N=+R.dataset.n||fr.length,par=R.dataset.par||'';
 var D={};try{D=JSON.parse(R.querySelector(':scope > .hk-anim-data').textContent);}catch(e){}
 var lbl=D.lbl||[],lienzo=fr.length===1&&N>1?fr[0].querySelector('canvas'):null;
 var sub=R.querySelector(':scope > .hk-anim-sub'),L=R.querySelector(':scope > .hk-anim-lbl'),bar=R.querySelector(':scope .hk-anim-bar'),
     bp=R.querySelector(':scope .hk-anim-play'),bv=R.querySelector(':scope .hk-anim-voz');
 function esc(s){return String(s).replace(/[&<>]/g,function(c){return c==='&'?'&amp;':c==='<'?'&lt;':'&gt;';});}
 /* voces: 1) #voz dentro de cada cuadro (bloques) 2) #voz pegadas despues de la animacion 3) las del C# */
 var voz=[];for(var i=0;i<N;i++)voz.push('');
 if(D.voz)for(var i=0;i<N&&i<D.voz.length;i++)voz[i]=esc(D.voz[i]);
 if(!lienzo)for(var i=0;i<fr.length;i++){var vs=fr[i].querySelectorAll('.hk-voz');if(vs.length){var h=[];vs.forEach(function(v){v.style.display='none';h.push((v.querySelector('.hk-voz-txt')||v).innerHTML);});voz[i]=h.join(' ');}}
 var host=R.closest('.hk-plotslot')||R,s=host.nextElementSibling,peg=[];
 while(s){var v=vozDe(s)||(s.children.length===1?vozDe(s.firstElementChild):null);if(!v)break;peg.push(v);s=s.nextElementSibling;}
 function junta(i,h){voz[i]=voz[i]?voz[i]+' '+h:h;}
 if(peg.length===1){for(var i=0;i<N;i++)junta(i,peg[0].innerHTML);}
 else for(var i=0;i<N&&i<peg.length;i++)junta(i,peg[i].innerHTML);
 function val(i){var t=lbl[i]||'';var k=t.indexOf('=');return k>=0?t.slice(k+1).trim():t;}
 for(var i=0;i<N;i++)if(voz[i]&&par)voz[i]=voz[i].split('⟦'+par+'⟧').join(esc(val(i)));
 var plano=voz.map(function(h){var d=document.createElement('div');d.innerHTML=h;return txt(d);});
 var i0=0,jugando=false,conVoz=false,tm=null,dt=+R.dataset.dt||1200;
 function show(i){i0=(i%N+N)%N;R.dataset.i=i0;
  if(lienzo){if(lienzo.hkFrame)lienzo.hkFrame(i0);else lienzo.dataset.frame=i0;}
  else for(var k=0;k<fr.length;k++)fr[k].style.visibility=(k===i0?'visible':'hidden');
  if(bar)bar.value=i0;if(L)L.innerHTML=esc(lbl[i0]||'')+' <span style=""color:var(--mut);font-size:.85em"">('+(i0+1)+'/'+N+')</span>';
  if(sub)sub.innerHTML=voz[i0]||'';}
 function dur(i){return plano[i]?Math.max(dt,55*plano[i].length):dt;}
 function para(){jugando=false;clearTimeout(tm);if(bp)bp.textContent='▶';}
 function paso(){clearTimeout(tm);if(!jugando)return;
  if(conVoz&&plano[i0]){var yo=i0;hkHabla(plano[i0],function(){if(!jugando||!conVoz||i0!==yo)return;tm=setTimeout(sig,350);});}
  else tm=setTimeout(sig,dur(i0));}
 function sig(){if(!jugando)return;if(conVoz&&i0===N-1){para();vozOff();return;}show(i0+1);paso();}
 function juega(){jugando=true;if(bp)bp.textContent='⏸';paso();}
 function vozOff(){conVoz=false;hkCalla();if(bv)bv.textContent='🔊';}
 if(bp)bp.onclick=function(){if(jugando){para();hkCalla();}else juega();};
 if(bar){var mv=function(){para();show(+bar.value);if(conVoz)hkHabla(plano[i0]);};bar.addEventListener('input',mv);bar.addEventListener('change',mv);}
 if(bv)bv.onclick=function(){if(conVoz){vozOff();return;}conVoz=true;bv.textContent='⏹';jugando=true;if(bp)bp.textContent='⏸';paso();};
 hkVoz(function(v){if(v&&bv&&plano.some(function(t){return !!t;}))bv.style.display='';R.dataset.voz=v?v.lang:'';});
 R.hkAnim={n:N,show:show,juega:juega,para:para,voz:plano,sub:voz,get i(){return i0;},get jugando(){return jugando;}};
 window.addEventListener('beforeprint',function(){para();show(0);});
 show(0);if(bp)bp.textContent='▶';
 setTimeout(function(){if(!jugando&&i0===0)juega();},1600);};
var st=document.createElement('style');st.textContent='@media print{.hk-anim-ctl{display:none!important}.hk-anim .hkfr{visibility:hidden!important}.hk-anim .hkfr[data-i=""0""]{visibility:visible!important}.hk-voz-btn{display:none!important}}';
(document.head||document.documentElement).appendChild(st);
})();}
";
    }
}
