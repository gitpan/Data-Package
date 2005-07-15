use inc::Module::Install;

name          ( 'Data-Package'                );
abstract      ( 'Base class for packages that are purely data' );
author        ( 'Adam Kennedy<cpan@ali.as>'   );
version_from  ( 'lib/Data/Package.pm'         );
license       ( 'perl'                        );

requires      ( 'perl'             => '5.005' );
requires      ( 'Class::Inspector' => '1.07'  );
requires      ( 'Params::Coerce'    => '0.06'  );

build_requires( 'File::Spec'       => '0.82'  );
build_requires( 'Test::More'       => '0.47'  );

auto_install();

&WriteAll;
